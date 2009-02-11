module Wiki
  class Node < ActiveRecord::Base
    set_table_name       :wikinode
    set_primary_key      :nodeid

    # com.liferay.portlet.wiki.model.WikiNode
    def liferay_class
      'com.liferay.portlet.wiki.model.WikiNode'
    end

    has_many :pages,
      :class_name  => "Wiki::Page",
      :foreign_key => "nodeid"
    alias :articles :pages

    has_many :resources,
      :class_name  => "Wiki::PageResource",
      :foreign_key => "nodeid"

  end
end
