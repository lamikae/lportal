module Tag
  class Property < ActiveRecord::Base
    set_table_name       :tagsproperty
    set_primary_key      :propertyid

    # com.liferay.portlet.tags.model.TagsProperty
    def liferay_class
      'com.liferay.portlet.tags.model.TagsProperty'
    end

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