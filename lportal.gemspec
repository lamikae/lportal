require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'version'

spec = Gem::Specification.new do |s|
  s.name = "lportal"
  s.version = Lportal::VERSION
  s.author = "Mikael Lammentausta"
  s.email = "mikael.lammentausta@gmail.com"
  s.homepage = "http://lportal.rubyforge.org/"
  s.rubyforge_project = "lportal"
  s.platform = Gem::Platform::RUBY
  s.summary = "Liferay ActiveRecord models."
  s.files = FileList["*.rb", "lib/**/*", "migrations/**/*"].to_a
  s.files.reject! { |fn| fn.include? "deprecated" }
  s.require_paths = ["."]
  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.autorequire = "init"
  s.extra_rdoc_files = ["README"]
  s.add_dependency("activerecord", ">= 1.2.6")
  s.add_dependency("uuidtools", "= 1.0.3")
end

desc 'Generate documentation for the application'
Rake::RDocTask.new('appdoc') { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Liferay ActiveRecord models'
  rdoc.options << ['-m lportal', '-U', '-x deprecated']
  rdoc.rdoc_files.include('README', 'ChangeLog')
  rdoc.rdoc_files.include('lib/**/*.rb')
}

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
