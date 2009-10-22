# helper for mysqladmin
def mysqladmin_exec(login,dbname,method)
	exec = "mysqladmin -u #{login.user} --password=#{login.pass} #{method} #{dbname} -f"
	puts exec
	`#{exec}`
end

# helper for dbconfig
def loadDbconf
	YAML.load_file('config/database.yml')
end

namespace :db do
	namespace :mysqladmin do
		
		desc 'creates DBs and DBUsers'
		task :create, [:user, :pass] do |t, args|
			mysqladmin_exec(args, loadDbconf['production']['database'], 'create')
			mysqladmin_exec(args, loadDbconf['test']['database'], 'create')
		end
		
		desc 'drops DBs and DBUsers'
		task :drop, [:user, :pass] do |t, args|
			dbconf = YAML.load_file('config/database.yml')
			mysqladmin_exec(args, loadDbconf['production']['database'], 'drop')
			mysqladmin_exec(args, loadDbconf['test']['database'], 'drop')
		end
	end
	
	desc 'imports liferay sql'
	task :import do
		
		ENV['LPORTAL_ENV'] = 'test'
		require 'db_connection'
		
		adapterName = ActiveRecord::Base.connection.adapter_name.downcase
		
		sql = File.open('vendor/liferay-portal-sql-5.2.3/create-minimal/create-minimal-'+adapterName+'.sql').read
		
		# slow crap :)
		#
		# sync = STDOUT.sync # save this value, whatever it might be :)
		# STDOUT.sync = true 	# immediately print..
		# sql.split(';').each do |sql_statement|
		# 	ActiveRecord::Base.connection.execute(sql_statement)
		# 	print '.'
		# end
		# STDOUT.sync = sync # restore
		
		ActiveRecord::Base.connection.execute(sql)
		
	end
end