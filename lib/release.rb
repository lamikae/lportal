class Release < ActiveRecord::Base

  def self.current
    self.find(:first, :order => "#{self.primary_key} DESC")
  end

end