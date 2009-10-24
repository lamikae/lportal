# helper for dbconfig
def loadDbconf
	YAML.load_file('config/database.yml')
end

namespace :db do
	namespace :mysql do
		
		desc 'creates DBs and DBUsers'
		task :create, [:user, :pass] do |t, args|
			if args.user.nil?
				puts "aborted, requires mysql admin user+pass!"
			else
				require "mysql"
                STDOUT.puts 'Connecting to MySQL with NO password' if args.pass.nil?

				# for each environment defined in database.yml
				loadDbconf.each do |e, confEnv|
					mysql = Mysql::new(confEnv['host'], args.user, args.pass, "mysql")
					mysql.query "CREATE DATABASE #{confEnv['database']} CHARACTER SET utf8;"
					mysql.query "GRANT ALL PRIVILEGES ON #{confEnv['database']}.* TO #{confEnv['username']}@'%' IDENTIFIED BY '#{confEnv['password']}';"
					mysql.query "FLUSH PRIVILEGES;"
				end	
			end
		end
		
		desc 'drops DBs and DBUsers'
		task :drop, [:user, :pass] do |t, args|
			if args.user.nil? || args.pass.nil?
				puts "aborted, requires mysql admin user+pass!"
			else
				require "mysql"
				# for each environment defined in database.yml
				loadDbconf.each do |e, confEnv|
					mysql = Mysql::new(confEnv['host'], args.user, args.pass, "mysql")
					mysql.query "DROP DATABASE #{confEnv['database']};"
					mysql.query "DROP USER #{confEnv['username']}@'%';"
					mysql.query "FLUSH PRIVILEGES;"
				end	
			end
		end

		task :import => :prepareimports do |t, args|

			require "mysql"
			# for each environment defined in database.yml
			loadDbconf.each do |e, confEnv|
				mysql = Mysql::connect(confEnv['host'], confEnv['username'], confEnv['password'], confEnv['database'])
				mysql.set_server_option(Mysql::OPTION_MULTI_STATEMENTS_ON)
				sqlBatch = File.open('tmp/prepared_imports.sql').read
				mysql.query(sqlBatch)
			end
				
		end
	end
	
	# prepare the vendor-sql-statements
	desc 'create tmp/prepared_imports.sql from vendor/..sql'
	task :prepareimports do
		
		# fixme other adapters..
		ENV['LPORTAL_ENV'] = 'test'
		require 'db_connection'
		adapterName = ActiveRecord::Base.connection.adapter_name.downcase
		
		sql = ''
		file = File.open('vendor/liferay-portal-sql-5.2.3/create-minimal/create-minimal-'+adapterName+'.sql')
		begin
			while (line = file.readline)
		  	if (line =~ /(drop|create) database|use /)
		  		sql += '-- ' + line
				else
					sql += line
				end
			end
		rescue EOFError
		    file.close
		end
        Dir.mkdir('tmp') unless File.exists?('tmp')
		File.open('tmp/prepared_imports.sql', 'w') {|f| f.write(sql) }
	end
	
end
