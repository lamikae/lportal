# Database
env = ENV['LPORTAL_ENV']

# Load ActiveRecord
require 'rails_gem_chooser'
RailsGemChooser.__load_gem('activerecord','2.3.4')

# Open database connection
database_configuration = YAML.load_file('config/database.yml')
ActiveRecord::Base.configurations = database_configuration
ActiveRecord::Base.establish_connection(database_configuration[env])
