require 'rubygems'
gem "spicycode-micronaut"
require 'micronaut'
require 'micronaut/rake_task'
require 'mocha'
require 'tempfile'
require File.dirname(__FILE__) + '/../lib/spec_converter'

Micronaut.configure do |config|
  config.mock_with :mocha
end

describe "converting from test/spec old style to new style names" do
  before do
    @converter = SpecConverter.new
  end
  
  it "replaces spec context with describe" do
    @converter.convert_line(%[context "should foo bar" do]).should == %[describe "should foo bar" do]
    @converter.convert_line(%[    context "should foo bar" do]).should == %[    describe "should foo bar" do]
  end
  
  it "ignores unrelated uses of 'context'" do
    @converter.convert_line(%[# here is a comment with context]).should == %[# here is a comment with context]
    @converter.convert_line(%[contexts.each do |context|]).should == %[contexts.each do |context|]
  end

  it "replaces spec specify with it" do
    @converter.convert_line(%[    specify "remember me saves the user" do]).should == %[    it "remember me saves the user" do]
  end
  
  it "ignores unrelated uses of 'specify'" do
    @converter.convert_line(%[# I like to specify things]).should == %[# I like to specify things]
    @converter.convert_line(%[  @user.should.specify.stuff]).should == %[  @user.should.specify.stuff]
  end
  
end

describe "SpecConverter.start" do
  it "creates an instance and calls convert" do
    SpecConverter.expects(:new).returns(converter = stub)
    converter.expects(:convert)
    SpecConverter.start
  end
end

describe "translate file overwrites old file with translated stuff" do
  it "works" do
    file = Tempfile.open("some_file.rb")
    file << "Here is some stuff that is cool!"
    file.close
    
    converter = SpecConverter.new
    converter.expects(:convert_line).with(anything).returns("Translated to be super awesome")
    converter.translate_file(file.path)

    File.open(file.path).read.should == "Translated to be super awesome"
  end
end

describe "converting dust style to test/spec style" do
  before do
    @converter = SpecConverter.new
  end
  
  it "changes test...do to it...do" do
    @converter.convert_line(%[test "should do something cool and fun!!" do]).should == %[it "should do something cool and fun!!" do]
  end
  
  it "ignores unrelated lines" do
    @converter.convert_line(%[# test that this class can do something right]).should == %[# test that this class can do something right]
  end

end

describe "converting ActionController tests to describe blocks" do
  before do
    @converter = SpecConverter.new
  end

  it "replaces class FooTest < ActionController::IntegrationTest with describe foo do" do
    @converter.convert_line(%[class ResearchTest < ActionController::IntegrationTest]).should == %[describe "Research", ActionController::IntegrationTest do]
  end
  
  it "replaces class FooControllerTest < ActionController::TestCase with describe foo do" do
    @converter.convert_line(%[class ResearchControllerTest < ActionController::TestCase]).should == %[describe "ResearchController", ActionController::TestCase do]
  end
  
  it "replaces class FooControllerTest < ActiveSupport::TestCase with describe foo do" do
    @converter.convert_line(%[class ResearchControllerTest < ActiveSupport::TestCase]).should == %[describe "ResearchController", ActiveSupport::TestCase do]
  end
end

describe "converting Test::Unit style to describe blocks" do
  before do
    @converter = SpecConverter.new
  end

  it "replaces class FooTest < Test::Unit::TestCase with describe foo do" do
    @converter.convert_line(%[class ResearchTest < Test::Unit::TestCase]).should == %[describe "Research" do]
  end

  it "replaces class FooTest < Test::Unit::TestCase with silly whitespacing with describe foo do" do
    @converter.convert_line(%[class ResearchTest       < Test::Unit::TestCase]).should == %[describe "Research" do]
  end
  
  it "converts namespaced test unit classes" do
    @converter.convert_line(%[class Admin::DashboardControllerTest < Test::Unit::TestCase]).should == %[describe "Admin::DashboardController" do]
  end

  it "ignores unrelated classes" do
    @converter.convert_line(%[class Foo]).should == %[class Foo]
    @converter.convert_line(%[class Bar < ActiveRecord::Base]).should == %[class Bar < ActiveRecord::Base]
  end

end

describe "converting Test::Unit methods to it blocks" do
  before do
    @converter = SpecConverter.new
  end
  
  it "replaces def setup with before do" do
    @converter.convert_line(%[def setup\n]).should == %[before do\n]
  end

  it "ignores method definitions that only start with setup" do
    @converter.convert_line(%[def setup_my_object]).should == %[def setup_my_object]
  end

  it "replaces class def test_something? with it something?  do" do
    @converter.convert_line(%[def test_something?]).should == %[it "something?" do]
  end

  it "replaces class def test_something? with it something?  do" do
    @converter.convert_line(%[def test_something?]).should == %[it "something?" do]
  end

  it "replaces class def test_something with it something do" do
    @converter.convert_line(%[def test_something]).should == %[it "something" do]
  end
  
  it "replaces class def test_something with it something do when it has leading whitespace" do
    @converter.convert_line(%[   def test_something_here]).should == %[   it "something here" do]
  end
  
  it "ignores unrelated lines" do
    @converter.convert_line(%[def foo]).should == %[def foo]
  end
  
  it "ignores unrelated lines with leading whitespace" do
    @converter.convert_line(%[   def foo]).should == %[   def foo]
  end

end

describe "converting assertions" do
  before do
    @converter = SpecConverter.new
  end
  
  it "replaces assert !foo to foo.should == false" do
    @converter.convert_line(%[    assert !foo]).should == %[    foo.should.not == true]
  end
  
  it "replaces assert_equal y, x, bar to x.should == y" do
    @converter.convert_line(%[    assert_equal "$1,490.00", x["price"]\n]).should == %[    x["price"].should == "$1,490.00"\n]
  end
  
  it "replaces assert foo to foo.should == true" do
    @converter.convert_line(%[    assert foo]).should == %[    foo.should.not == nil]
  end
  
  it "replaces assert_nil foo to foo.should == nil" do
    @converter.convert_line(%[    assert_nil foo]).should == %[    foo.should == nil]
  end

  it "replaces assert_true foo to foo.should == true" do
    @converter.convert_line(%[    assert_true foo]).should == %[    foo.should == true]
  end

  it "replaces assert_false foo to foo.should == false" do
    @converter.convert_line(%[    assert_false foo]).should == %[    foo.should == false]
  end

  it "replaces assert_not_nil foo to foo.should.not == nil" do
    @converter.convert_line(%[    assert_not_nil foo]).should == %[    foo.should.not == nil]
  end  
  it "replaces assert foo > 20 to foo.should > 20" do
    @converter.convert_line(%[    assert foo > 20]).should == %[    foo.should > 20]
  end
end

describe "converting things in batch" do
  before do
    @converter = SpecConverter.new
  end
  
  it "takes convert all test files in the test subdirectory" do
    @convert.expects(:convert_line).never
    files = %w[test/foo_test.rb test/models/another_test.rb]
    files.each do |file|
      @converter.expects(:translate_file).with(file)
    end
    Dir.expects(:glob).with(anything()).returns(files)
    File.stubs(:directory?).with("test").returns(true)
    @converter.convert
  end
end