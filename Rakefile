require 'rake'
require 'rake/testtask'
require 'rubygems'
require 'lib/spec_converter'
require 'rcov/rcovtask'
require 'echoe'

Echoe.new("spec_converter") do |p|
  p.rubyforge_name = "thinkrelevance"
  p.description = "Convert your tests to test/spec specs.  See http://opensource.thinkrelevance.com/wiki/spec_converter for details."
  p.name = 'spec_converter'
  p.summary = "Convert your tests to test/spec specs"
  p.author = "Relevance"
  p.email = "opensource@thinkrelevance.com"
  p.url = "http://opensource.thinkrelevance.com/wiki/spec_converter"
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Default for CruiseControl'
task :cruise => ['test', 'test:flog']

desc 'Test for flog failure'
namespace :test do
  task :flog do
    threshold = (ENV['FLOG_THRESHOLD'] || 120).to_i
    dirs = %w(lib tasks test)
    result = IO.popen("flog #{dirs.join(' ')} 2>/dev/null | grep \"(\" | grep -v \"main#none\" | head -n 1").readlines.join('')
    result =~ /\((.*)\)/
    flog = $1.to_i
    result =~ /^(.*):/
    method = $1
    if flog > threshold
      raise "FLOG failed for #{method} with score of #{flog} (threshold is #{threshold})."
    end  
    puts "FLOG passed, with highest score being #{flog} for #{method}."
  end
end

desc 'Run all tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

Rcov::RcovTask.new("rcov") do |t|
  rcov_output = "tmp/coverage"
  FileUtils.mkdir_p rcov_output unless File.exist? rcov_output
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
  t.output_dir = "#{rcov_output}/"
  t.verbose = true
  t.rcov_opts = ["-x", "^/Library", "--sort coverage"]
end          
