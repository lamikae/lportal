namespace :db do

  desc "Migrates lportal database tables"
  task :migrate => :environment do

    # first run lportal sequence migrations (TODO)
    info('Running lportal migrations')
    ActiveRecord::Migrator.migrate(LPORTAL_MIGRATIONS)

    #Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    info 'You need to manually run rake db:schema:dump'

    #Rake::Task['db:update'].invoke
  end

  desc "Wipes out lportal database tables"
  task :rollback => :environment do

    version = ENV['VERSION'].to_i || 0

    info('Reverting lportal migrations')
    ActiveRecord::Migrator.migrate(LPORTAL_MIGRATIONS, version)

    #Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    info 'You need to manually run rake db:schema:dump'
  end

end