class SocialRelation < ActiveRecord::Base
  set_table_name       :socialrelation
  set_primary_key      :relationid

  # com.liferay.portlet.social.model.SocialRelation
  def liferay_class
    'com.liferay.portlet.social.model.SocialRelation'
  end

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :user1,
    :foreign_key => 'userid1'

  belongs_to :user2,
    :foreign_key => 'userid2'

end
