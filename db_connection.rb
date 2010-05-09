# encoding: utf-8

# Database
env = ENV['LPORTAL_ENV'] # 'test' or 'production' are valid
rails_gem_version = ENV['RAILS_GEM_VERSION']

# Load ActiveRecord
require 'rails_gem_chooser'
RailsGemChooser.__load_gem('activerecord',rails_gem_version)

# Open database connection
database_configuration = YAML.load_file('config/database.yml')
ActiveRecord::Base.configurations = database_configuration
ActiveRecord::Base.establish_connection(database_configuration[env])
