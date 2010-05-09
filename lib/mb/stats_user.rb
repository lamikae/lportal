# encoding: utf-8

module MB
  class StatsUser < ActiveRecord::Base

    belongs_to :user,
      :foreign_key => User.primary_key

    belongs_to :group,
      :foreign_key => Group.primary_key

  end
end