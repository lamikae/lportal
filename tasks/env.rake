namespace :db do
  task :environment do
    ENV['LPORTAL_ENV'] = 'production'
    require 'db_connection'
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger.level = Logger::FATAL
    require 'init'
  end
end

namespace :test do
  task :environment do
    # in test_helper
  end
end
