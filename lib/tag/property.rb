module Tag
  class Property < ActiveRecord::Base

    # association to user
    belongs_to :user,
      :foreign_key => 'userid'
    alias :owner :user

    belongs_to :company,
      :foreign_key => 'companyid'

    belongs_to :tag,
      :class_name => 'Tag::Entry',
      :foreign_key => 'entryid'

    def category
      (self.key_=='category' ? self.value : nil)
    end

  end
end