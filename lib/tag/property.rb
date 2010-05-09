# encoding: utf-8

module Tag
  class Property < ActiveRecord::Base

    belongs_to :user,
      :foreign_key => User.primary_key
    alias :owner :user

    belongs_to :company,
      :foreign_key => Company.primary_key

    belongs_to :tag,
      :class_name => 'Tag::Entry',
      :foreign_key => Tag::Entry.primary_key

    def category
      (self.key_=='category' ? self.value : nil)
    end

  end
end