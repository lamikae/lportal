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


    # PortletPreferences instance keeps record of unique Portlet preferences.
    #
    # Parameteres:
    #  - portletid (String) (or portlet)
    #  - portlet       Web::Portlet
    #  - preferences   String
    #  - instantiate   Boolean
    def initialize(params={})
      @instantiate = params.delete(:instantiate)
      if params[:portletid]
        portlet = params.delete(:portlet)
      end

      super(params)

      self.preferences ||= '<portlet-preferences />'
      self.ownerid     ||= 0 # ??
      self.ownertype   ||= 3 # ??

      self.portlet = portlet if portlet # this has to be after calling super
      self
    end

    # defines the portlet that the preferences describe.
    def portlet=(portlet)
      portletid = '%s' % portlet.portletid
      portletid << ('_INSTANCE_%s' % self.class.random_string(4)) if @instantiate==true
      self.portletid = portletid
    end
    
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


    private

    def self.random_string(len=10)
      chars = ('a'..'z').to_a + ('A'..'Z').to_a
      (0...len).collect { chars[Kernel.rand(chars.length)] }.join
    end

  end
end