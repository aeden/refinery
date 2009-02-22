require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run tests.'
task :default => [:test]

desc 'Test the active_warehouse plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end