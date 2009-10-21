# Lportal bootstrap.
# This prepares the environment by loading a set of active_record patches.

require 'active_record'

file = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
this_dir = File.dirname(File.expand_path(file))

# set the migrations directory for Caterpillar
LPORTAL_MIGRATIONS=File.expand_path(
  File.join(this_dir,'migrations')
              )

require File.join(this_dir,'version')

def info(msg)
  msg = 'lportal: %s' % msg
#   defined?(RAILS_DEFAULT_LOGGER) ?
#     RAILS_DEFAULT_LOGGER.info(msg) : STDOUT.puts(msg)
  STDOUT.puts(msg)
end

info 'version ' + Lportal::VERSION

### DATABASE HACKS
# FIXME: the whole process of DB hacks is unclean.

  # MySQL; load class definitions BEFORE patching AR,
  # otherwise ”uninitialized constant Account”
  if ActiveRecord::Base.connection.adapter_name=='MySQL'
    require File.join(this_dir,'class-definitions')
  end

  # load a set of monkey patches that alter the functionality a bit based on the database type
  require File.join(this_dir,'active_record','base')
  info 'using %s adapter' % ActiveRecord::Base.connection.adapter_name
  case ActiveRecord::Base.connection.adapter_name
  when 'PostgreSQL'
    require File.join(this_dir,'active_record','connection_adapters','postgresql_adapter')
  when 'MySQL'
  require File.join(this_dir,'mysql')
  else
    STDERR.puts 'You are using a database that is not supported by the lportal Ruby library.'
    STDERR.puts 'Please join the mailing list at http://rubyforge.org/mail/?group_id=7349'
  end

  # PostgreSQL; load class definitions AFTER patching AR
  if ActiveRecord::Base.connection.adapter_name=='PostgreSQL'
    require File.join(this_dir,'class-definitions')
  end

### end of DATABASE HACKS

# make models able to act resourceful
require File.join(this_dir,'lib','acts','resourceful')
ActiveRecord::Base.class_eval { include Acts::Resourceful }

# Define Liferay (asset viewer) portlets.
# This class is for defining specific portlet functionality.
require File.join(this_dir,'portlets')

# include all database models from lib
require 'find'
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

# portal methods
require File.join(this_dir,'lportal')

# define this database's schema version
require File.join(this_dir,'schema')
release = Release.current
last_supported_release = 5201
begin
    Lportal::Schema.buildnumber = (
    if release
        msg = 'detected'
        release.buildnumber
    else
        msg = 'using default'
        last_supported_release
    end
    )
rescue
    STDERR.puts ' ***'
    STDERR.puts ' * Either you do not have a proper Liferay schema or you have encountered a bug in lportal.'
    STDERR.puts ' * Please contact the mailing list for support. Describe your setup and paste the trace below.'
    STDERR.puts ' ***'
    raise $!
end

msg << ' Liferay schema build %i, version %s' % [
  Lportal::Schema.buildnumber, Lportal::Schema.version]

info(msg)
