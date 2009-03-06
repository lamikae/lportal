require 'find'
require 'active_record'

file = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
this_dir = File.dirname(File.expand_path(file))

require this_dir+'/version'

# set the migrations directory
LPORTAL_MIGRATIONS=File.expand_path(
  File.join(this_dir,'migrations','*.rb')
              )

require File.join(this_dir,'lib','acts','resourceful')
# make models able to act resourceful
ActiveRecord::Base.class_eval { include Acts::Resourceful }

# include all ruby files
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

