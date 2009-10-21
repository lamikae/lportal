require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

# appends test_helper to path
$: << File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the lportal gem.'
Rake::TestTask.new(:test) do |t|
  chdir 'test'
  t.libs << 'lib'
  t.pattern = '**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the liferay plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Liferay ActiveRecord models'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.options << '-U' << '-x deprecated'
  rdoc.options << '--line-numbers' << '--inline-source'
end
