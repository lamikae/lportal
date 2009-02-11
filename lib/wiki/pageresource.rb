module Wiki
  class PageResource < ActiveRecord::Base
    set_table_name       :wikipageresource
    set_primary_key      :resourceprimkey

    # com.liferay.portlet.wiki.model.WikiPageResource
    def liferay_class
      'com.liferay.portlet.wiki.model.WikiPageResource'
    end

    # association to WikiNode
    belongs_to :node,
      :class_name  => "Wiki::Node",
      :foreign_key => "nodeid"

    has_one :asset,
      :class_name  => 'Tag::Asset',
      :foreign_key => 'classpk'

  end
end
