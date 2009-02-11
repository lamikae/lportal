module Web
  class PortletPreferences < ActiveRecord::Base
    set_table_name       :portletpreferences
    set_primary_key      :portletpreferencesid

    public

    belongs_to :layout,
      :class_name => 'Web::Layout',
      :foreign_key => 'plid'

    belongs_to :owner,
      :class_name => 'User',
      :foreign_key => 'ownerid'

    def name
      self.portletid.split(/_INSTANCE_/)[0]
    end

    # primkey in resource_ table
    def primkey
      "#{self.plid}_LAYOUT_#{self.portletid}"
    end

    # argument plid is to comply API with Web::Portlet.resource
    def resource(plid=nil)
      Resource.find_by_primkey(self.primkey)
  #     Resource.find(:all, :conditions => "primkey='#{self.primkey}'")
    end

    # loads the preferences XML structure to Ruby Hash
    def preferences_
      xml = REXML::Document.new(self.preferences)
      preferences = []
      xml.elements.each("portlet-preferences/preference") do |pref|
        phash = {
          :name  => pref.elements["name"].text,
          :value => (pref.elements["value"] ? pref.elements["value"].text : "")
        }
        preferences << phash
      end
      return preferences
    end

  end
end