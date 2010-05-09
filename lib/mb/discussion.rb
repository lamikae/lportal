# encoding: utf-8

module MB
  class Discussion < ActiveRecord::Base

    belongs_to :thread,
      :class_name => "MB::Thread",
      :foreign_key => "threadid"

  end
end