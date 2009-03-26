class Release < ActiveRecord::Base
  set_table_name       :Release_
  set_primary_key      :releaseId

  def self.current
    self.find(:first, :order => "#{self.primary_key} DESC")
  end
  
#   # Returns the value of the column. Depends on the database type. Experimental.
#   def buildnumber
#     if connection.adapter_name=='PostgreSQL'
#       super
#     else
#       self.buildNumber
#     end    
#   end

end