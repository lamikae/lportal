class Release < ActiveRecord::Base
  set_table_name       :release_
  set_primary_key      :releaseid

  def self.current
    self.find(:first, :order => "releaseid ASC")
  end

end