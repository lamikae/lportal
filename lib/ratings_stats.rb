class RatingsStats < ActiveRecord::Base
  set_table_name       :ratingsstats
  set_primary_key      :statsid

  # com.liferay.portlet.ratings.model.RatingsStats
  def liferay_class
    'com.liferay.portlet.ratings.model.RatingsStats'
  end

  def initialize(params)
    super(params)
    self.totalentries ||= 0
    self.totalscore   ||= 0
    self.averagescore ||= 0
    self.save
  end

end
