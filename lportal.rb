# Lportal models.
# This prepares the environment by loading a set of active_record patches.

file = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
this_dir = File.dirname(File.expand_path(file))

# load class definitions
require File.join(this_dir,'class-definitions')

# make models able to act resourceful
require File.join(this_dir,'lib','acts','resourceful')
ActiveRecord::Base.class_eval { include Acts::Resourceful }

# Define Liferay (asset viewer) portlets.
# This class is for defining specific portlet functionality.
require File.join(this_dir,'portlets')

require 'find'

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

