class SocialActivity < ActiveRecord::Base

  belongs_to :company,
    :foreign_key => Company.primary_key

  belongs_to :user,
    :foreign_key => User.primary_key

  belongs_to :group,
    :foreign_key => Group.primary_key

  def initialize(params)
    super(params)
    self.createdate       ||= Time.now
    self.mirroractivityid ||= 0
    self.type_            ||= 1
    self.extradata        ||= ''
    self.receiveruserid   ||= 0
    self.save
  end

end
