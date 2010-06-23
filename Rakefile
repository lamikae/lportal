require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

ENV['RAILS_GEM_VERSION'] = '2.3.4' # FIXME: test suite does not work on older versions!

def info(msg)
  STDOUT.puts msg
end

require 'rubygems'
require 'activerecord'
require 'erb'

load 'tasks/env.rake'
load 'tasks/fixtures.rake'
load 'tasks/migrate.rake'
load 'tasks/database.rake'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the lportal gem.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
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
