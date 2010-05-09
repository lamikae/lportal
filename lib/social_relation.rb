# encoding: utf-8

class SocialRelation < ActiveRecord::Base

  belongs_to :company,
    :foreign_key => Company.primary_key

  belongs_to :user1,
    :foreign_key => 'userid1'

  belongs_to :user2,
    :foreign_key => 'userid2'

end
