module Web
  # While PortletPreferences acts_as_resourceful, it is a resource as the portlet it represents.
  # The ResourceCode has a 'name' value that is the Portlet's portletid.
  class PortletPreferences < ActiveRecord::Base
    set_table_name       :portletpreferences
    set_primary_key      :portletpreferencesid

    acts_as_resourceful

    public

    belongs_to :layout,
      :class_name => 'Web::Layout',
      :foreign_key => 'plid'

    belongs_to :owner,
      :class_name => 'User',
      :foreign_key => 'ownerid'


    # Actions for Permissions. This list is not complete.
    def self.actions
      %w{
      VIEW
      }
    end

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
    # Instantiates if the portlet can instantiated.
    def portlet=(portlet)
      self.portletid = (
        portlet.instanceable? ?
          self.class.instance_id(portlet.portletid) : portlet.portletid
      )
    end

    # The Web::Portlet of this "preferences".
    def portlet
      return nil unless self.layout
      Web::Portlet.find(:first,
        :conditions => "companyid=#{self.layout.companyid} AND portletid='#{self.name}'")
    end

    # the portletid (name) of the portlet
    def name
      self.portletid.split(/_INSTANCE_/)[0]
    end

    # primkey is the foreign key in the resource_ table.
    def primkey
      "#{self.plid}_LAYOUT_#{self.portletid}"
    end

    # Translates the preferences XML structure to Array of Hashes.
    def to_a
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

    def companyid
      self.layout.companyid
    end

    # Override acts_as_resourceful. Use portlet name as the ResourceCode name.
    def resource_code(scope=4)
      ResourceCode.get({
        :companyid => self.companyid,
        :name      => self.name,
        :scope     => scope
      })
    end

    def scope2_primkey
      self.layout ?
        self.layout.groupid : nil
    end

    def scope4_primkey
      self.primkey
    end

    private

    def self.random_string(len=10)
      chars = ('a'..'z').to_a + ('A'..'Z').to_a
      (0...len).collect { chars[Kernel.rand(chars.length)] }.join
    end

  end
end