module MB
  class Thread < ActiveRecord::Base

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
