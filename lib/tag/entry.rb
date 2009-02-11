module Tag
  class Entry < ActiveRecord::Base
    set_table_name       :tagsentry
    set_primary_key      :entryid

    # com.liferay.portlet.tags.model.TagsEntry
    def liferay_class
      'com.liferay.portlet.tags.model.TagsEntry'
    end

    # association to user
    belongs_to :user,
      :foreign_key => 'userid'
    alias :owner :user

    belongs_to :company,
      :foreign_key => 'companyid'

    has_many :properties,
      :class_name => 'Tag::Property',
      :foreign_key => 'entryid'

    # association to assets
    has_and_belongs_to_many  :assets,
      :class_name              => 'Tag::Asset',
      :join_table              => 'tagsassets_tagsentries',
      :foreign_key             => 'entryid',
      :association_foreign_key => 'assetid'

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