require 'find'
require 'active_record'

file = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
this_dir = File.dirname(File.expand_path(file))

require File.join(this_dir,'version')

# set the migrations directory for Caterpillar
LPORTAL_MIGRATIONS=File.expand_path(
  File.join(this_dir,'migrations')
              )

# make models able to act resourceful
require File.join(this_dir,'lib','acts','resourceful')
ActiveRecord::Base.class_eval { include Acts::Resourceful }

# Define Liferay (asset viewer) portlets.
# This class is for defining specific portlet functionality.
require File.join(this_dir,'portlets')

# include all models from lib
Find.find(File.join(this_dir,'lib')) do |file|
  if FileTest.directory?(file)
    if File.basename(file) == "deprecated"
      Find.prune # Don't look any further into this directory.
    else
      next
    end
  else
    require file if file[/.rb$/]
  end
end

# define this database's schema version
require File.join(this_dir,'schema')
Lportal::Schema.buildnumber = 
  begin
    Release.current.buildnumber
  rescue
    nil
  end

msg = 'Using Liferay schema build %i, version %s' % [
  Lportal::Schema.buildnumber, Lportal::Schema.version]

defined?(RAILS_DEFAULT_LOGGER) ?
  RAILS_DEFAULT_LOGGER.info(msg) : STDOUT.puts(msg)

puts 'ActiveRecord v.%s' % ActiveRecord::VERSION::STRING
