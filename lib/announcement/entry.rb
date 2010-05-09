# encoding: utf-8

module Announcement
  class Entry < ActiveRecord::Base

    belongs_to :company,
      :foreign_key => Company.primary_key

    belongs_to :user,
      :foreign_key => User.primary_key

#     has_one :asset,
#       :foreign_key => 'classpk'

  end
end
