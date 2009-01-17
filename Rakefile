require 'rake'
require 'rake/testtask'
require 'rubygems'
require 'lib/spec_converter'
require 'rcov/rcovtask'
require 'echoe'
gem "spicycode-micronaut"
require 'micronaut'
require 'micronaut/rake_task'

Echoe.new("spec_converter") do |p|
  p.rubyforge_name = "thinkrelevance"
  p.description = "Convert your tests to test/spec specs.  See http://github.com/relevance/spec_converter/ for details."
  p.name = 'spec_converter'
  p.summary = "Convert your tests to test/spec specs"
  p.author = "Relevance"
  p.email = "opensource@thinkrelevance.com"
  p.url = "http://github.com/relevance/spec_converter/"
  p.rdoc_pattern = /^(lib|bin|ext)|txt|rdoc|CHANGELOG|MIT-LICENSE$/
  rdoc_template = `allison --path`.strip << ".rb"
  p.rdoc_template = rdoc_template
end

task(:default).clear

desc 'Default: run examples.'
task :default => :examples

desc "Run all micronaut examples"
Micronaut::RakeTask.new(:examples)

namespace :examples do
  desc "Run all micronaut examples using rcov"
  Micronaut::RakeTask.new :coverage do |t|
    t.pattern = "examples/**/*_example.rb"
    t.rcov = true
    t.rcov_opts = %[--exclude "gems/*,/Library/Ruby/*,config/*" --text-summary  --sort coverage --no-validator-links]
  end
end
