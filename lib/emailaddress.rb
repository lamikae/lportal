# encoding: utf-8

class Emailaddress < ActiveRecord::Base

  belongs_to :company,
    :foreign_key => Company.primary_key

  belongs_to :user,
    :foreign_key => User.primary_key

end
