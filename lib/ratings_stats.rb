class RatingsStats < ActiveRecord::Base

  def initialize(params)
    super(params)
    self.totalentries ||= 0
    self.totalscore   ||= 0
    self.averagescore ||= 0
    self.save
  end

end
