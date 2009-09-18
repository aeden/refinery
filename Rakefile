require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run tests.'
task :default => [:test]

desc 'Run tests.'
task :test do
  Dir.glob('test/**/*_test.rb') do |f|
    require f
  end
end

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Refinery'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/*.rb')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "refinery"
    gemspec.summary = "Refinery processes data in a distributed environment."
    gemspec.email = "anthonyeden@gmail.com"
    gemspec.homepage = "http://github.com/aeden/refinery"
    gemspec.description = "Process data in a distributed fashion."
    gemspec.authors = ["Anthony Eden"]
    gemspec.files.exclude 'docs/**/*'
    gemspec.files.exclude '.autotest'
    gemspec.rubyforge_project = 'refinery'
    gemspec.add_dependency "right_aws"
    gemspec.add_dependency "moneta"
    gemspec.add_dependency "addressable"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
