# encoding: utf-8

# Database
env = ENV['LPORTAL_ENV'] # 'test' or 'production' are valid

# Open database connection
database_configuration = YAML.load_file('config/database.yml')
ActiveRecord::Base.configurations = database_configuration
ActiveRecord::Base.establish_connection(database_configuration[env])
