require 'find'
require 'active_record'

file = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
this_dir = File.dirname(File.expand_path(file))

require this_dir+'/version'

# include all ruby files
Find.find(this_dir+'/lib') do |file|
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
