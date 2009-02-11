module Web
  # Not all portlets are necessarily saved in the database.
  class Portlet < ActiveRecord::Base
    set_table_name       :portlet
    set_primary_key      :id_

    public

    belongs_to :company,
      :foreign_key => "companyid"

    def name
      self.portletid
    end

    # primkey in resource_ table
    def primkey(plid)
      "#{plid}_LAYOUT_#{self.portletid}"
    end

    def resource(plid)
      Resource.find_by_primkey(self.primkey(plid))
    end

    # all instances
    def resources
  #     Resource.find_by_primkey(self.primkey)
  #     Resource.find(:all, :conditions => "primkey='#{self.primkey}'")
      resources = []
      ResourceCode.find(:all, :conditions => "name='#{portletid}'").each do |rc|
        resources << Resource.find(:all, :conditions => "codeid='#{rc.id}'")
      end

      return resources.flatten
    end

    def is_active?
      self.active_
    end

    # comply API with Web::PortletPreferences
    def preferences_
      ""
    end

  end
end