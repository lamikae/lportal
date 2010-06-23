desc 'Creates YAML fixtures from live data.'
task :fixtures do
  ENV['LPORTAL_ENV'] = 'production'
  require 'db_connection'
  require 'init'
  require 'test/test_case'

  unless File.exists?(ActiveSupport::TestCase.fixture_path)
    Dir.mkdir(ActiveSupport::TestCase.fixture_path)
  end

  sql = "SELECT * from %s"

  ActiveRecord::Base.connection.tables.each do |table|
    i = "000"
    File.open(
      File.join(
        ActiveSupport::TestCase.fixture_path,
        table+'.yml'),
      'w'
    ) do |file|
      puts "* %s" % file.inspect
      data = ActiveRecord::Base.connection.select_all(sql % table)
      file.write data.inject({}) { |hash, record|
        hash["#{table}_#{i.succ!}"] = record
        hash
      }.to_yaml
    end
  end
end
