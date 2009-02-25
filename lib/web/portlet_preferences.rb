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
    def initialize(params={})
      portlet = params.delete(:portlet) if params[:portlet]

      super(params)

      self.preferences ||= '<portlet-preferences />'
      self.ownerid     ||= 0 # ??
      self.ownertype   ||= 3 # ??

      # since the instance in not yet saved, the portletid might be integer
      portlet ||= Web::Portlet.find_by_portletid("#{self.portletid}")
      if portlet
        self.portlet = portlet # instantiates if applicaple
      else
        # nil is most likely an error. the portlet database is not populated?
        # in this case default to fallback action and instantiate the portlet.
        self.portletid = self.class.instance_id(self.portletid)
      end
      self
    end

    # generates a random instance id
    def self.instance_id(portletid)
      '%s_INSTANCE_%s' % [portletid, random_string(4)]
    end

    # Defines the portlet that the preferences describe.
    # Instantiates if the portlet can instantiate.
    def portlet=(portlet)
      if portlet.instanceable?
        self.portletid = self.class.instance_id(portlet.portletid)
      else
        self.portletid = portlet.portletid
      end
    end

    def portlet
      Web::Portlet.find_by_portletid(self.name)
    end
    
    # the portletid (name) of the portlet
    def name
      self.portletid.split(/_INSTANCE_/)[0]
    end

    # primkey in resource_ table
    def primkey
      "#{self.plid}_LAYOUT_#{self.portletid}"
    end

    # Argument plid is to comply API with Web::Portlet.resource
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