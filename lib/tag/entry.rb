# encoding: utf-8

module Tag
  class Entry < ActiveRecord::Base

    # association to user
    belongs_to :user,
      :foreign_key => User.primary_key
    alias :owner :user

    belongs_to :company,
      :foreign_key => Company.primary_key

    has_many :properties,
      :class_name => 'Tag::Property',
      :foreign_key => self.primary_key

    # association to assets
    has_and_belongs_to_many  :assets,
      :class_name              => 'Tag::Asset',
      :join_table              => 'TagsAssets_TagsEntries',
      :foreign_key             => self.primary_key,
      :association_foreign_key => Tag::Asset.primary_key

    def categories
      self.properties.map{|p| p.category}.compact.uniq
    end

#     def categories<<(category)
#       return false if self.categories.include? category
#       Tag::Property.create(
#         :entryid      => self.id,
#         :key_         => 'category',
#         :value        => category,
#         :companyid    => self.company.id,
#         :createdate   => Time.now,
#         :modifieddate => Time.now
#       )
#     end

  end
end