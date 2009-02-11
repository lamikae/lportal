module Wiki
  class Page < ActiveRecord::Base
    set_table_name       :wikipage
    set_primary_key      :pageid

    # com.liferay.portlet.wiki.model.WikiPage
    def liferay_class
      'com.liferay.portlet.wiki.model.WikiPage'
    end

    belongs_to :company,
      :foreign_key => 'companyid'

    # association to WikiNode
    belongs_to :node,
      :class_name  => 'Wiki::Node',
      :foreign_key => 'nodeid'

    belongs_to :user,
      :foreign_key => 'userid'
    alias :writer :user

    belongs_to :resource,
      :class_name => 'Wiki::PageResource',
      :foreign_key => 'resourceprimkey'

    def asset
      self.resource.asset
    end

  end
end
