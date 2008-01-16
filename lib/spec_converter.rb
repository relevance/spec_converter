# Simple converter to go to test/spec style
# This will change all files in place, so make sure you are properly backed up and/or committed to SVN!
class SpecConverter
  VERSION = "0.0.3"
  
  def self.start
    spec_converter = SpecConverter.new
    spec_converter.convert
  end
  
  # Convert tests from old spec style to new style -- assumes you are in your project root and globs all tests 
  # in your test directory.  
  def convert
    raise "No test diretory - you must run this script from your project root, which should also contain a test directory." unless File.directory?("test")
    tests = Dir.glob('test/**/*_test.rb')
    tests.each do |test_file|
      translate_file(test_file)
    end
  end
  
  def translate_file(file)
    translation = ""
    File.open(file) do |io|
      io.each_line do |line|
        translation << convert_line(line)
      end
    end
    File.open(file, "w") do |io|
      io.write(translation)
    end
  end
  
  def convert_line(line)
    convert_rspec_old_style_names(line)
    convert_dust_style(line)
    convert_test_unit_class_name(line)
    convert_test_unit_methods(line)
    convert_def_setup(line)
    convert_assert(line)
    line
  end
  
  private

  def convert_def_setup(line)
    line.gsub!(/(^\s*)def setup(\s*)$/, '\1before do\2')
  end
  
  def convert_rspec_old_style_names(line)
    line.gsub!(/(^\s*)context(\s.*do)/, '\1describe\2')
    line.gsub!(/(^\s*)specify(\s.*do)/, '\1it\2')
  end

  def convert_test_unit_class_name(line)
    line.gsub!(/^class\s*([\w:]+)Test\s*<\s*Test::Unit::TestCase/, 'describe "\1" do')
    line.gsub!(/^class\s*([\w:]+)Test\s*<\s*ActionController::IntegrationTest/, 'describe "\1", ActionController::IntegrationTest do')
  end
  
  def convert_test_unit_methods(line)
    line.gsub!(/(^\s*)def\s*test_([\w_!?,$]+)/) { %{#{$1}it "#{$2.split('_').join(' ')}" do} }
  end
  
  def convert_dust_style(line)
    line.gsub!(/(^\s*)test(\s.*do)/, '\1it\2')
  end
  
  def convert_assert(line)
    line.gsub!(/(^\s*)assert\s+([^\s]*)\s*([<=>~]+)\s*(.*)$/, '\1\2.should \3 \4' )
    line.gsub!(/(^\s*)assert\s+\!(.*)$/, '\1\2.should.not == true' )
    line.gsub!(/(^\s*)assert\s+(.*)$/, '\1\2.should.not == nil' )
    line.gsub!(/(^\s*)assert_equal\s+([^\(.]*),\s*(.*)$/, '\1\3.should == \2' )
  end
end