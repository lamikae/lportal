# encoding: utf-8

module MB
  class Thread < ActiveRecord::Base

    # Creates a new Thread.
    #
    def initialize(params)
      super(params)
      self.messagecount ||= 0
      self.viewcount    ||= 0
      self.save
    end

    belongs_to :category,
      :class_name => 'MB::Category',
      :foreign_key => 'categoryid'

    belongs_to :rootmessage,
      :class_name => 'MB::Message',
      :foreign_key => 'rootmessageid'

    has_many :messages,
      :class_name => 'MB::Message',
      :foreign_key => 'threadid',
      :order => :createdate


    def first_entry
      self.rootmessage
    end

  end
end
