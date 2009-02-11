class SocialActivity < ActiveRecord::Base
  set_table_name       :socialactivity
  set_primary_key      :activityid

  # com.liferay.portlet.social.model.SocialActivity
  def liferay_class
    'com.liferay.portlet.social.model.SocialActivity'
  end

  belongs_to :group,
    :foreign_key => 'groupid'

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :user,
    :foreign_key => 'userid'

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
