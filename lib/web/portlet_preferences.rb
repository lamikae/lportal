module Web
  # While PortletPreferences acts_as_resourceful, it is a resource as the portlet it represents.
  # The ResourceCode has a 'name' value that is the Portlet's portletid.
  class PortletPreferences < ActiveRecord::Base
    set_table_name       :portletpreferences
    set_primary_key      :portletpreferencesid

    acts_as_resourceful

    include Lportal::Portlets

    public

    belongs_to :layout,
      :class_name => 'Web::Layout',
      :foreign_key => 'plid'

# this is more complicated than this.
#     belongs_to :owner,
#       :class_name => 'User',
#       :foreign_key => 'ownerid'


    # Actions for Permissions.
    def self.actions
      %w{
        CONFIGURATION
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
      unless @portlet
        unless self.companyid
          puts 'oops'
          logger.warn 'Requested portlet of portletpreferences -- yet no companyid could be fetched.'
          @portlet = nil
        else
          puts 'ok'
          puts self.portlet_id
          @portlet = Web::Portlet.find(:first,
            :conditions => "companyid=#{self.companyid} AND portletid='#{self.portlet_id}'")
        end
      end
      puts @portlet.inspect
      return @portlet
    end

    # Various static properties of the portlet instance and the portlet in general.
    # Requires custom migrations for PortletProperties.
    # The tables within are filled by Caterpillar, since it knows the location of the
    # portlet XML files.
    #
    # This is intentionally duplicated for Web::Portlet to minimize database queries.
    def properties
      unless @properties
        @properties = Web::PortletProperties.find_by_portletid(self.portlet_id)
      end
      return @properties
    end

    # The portletid of the Web::Portlet. <tt>portletid</tt> is still the actual portletid of the instance.
    def portlet_id
      self.portletid.split(/_INSTANCE_/)[0]
    end

    # the 4-char random string
    def instance_id
      self.portletid.split(/_INSTANCE_/)[1]
    end

    # The default title string that is displayed. Requires custom migrations for PortletProperties.
    # Rails-portlets override this, with the value of <head><title>.
    # There are no Ruby setters yet, this value is read-only.
    #
    # TODO: parse self.preferences:
    # <portlet-preferences>
    #   <preference>
    #     <name>portlet-setup-title-fi_FI</name>
    #     <value>my custom title</value>
    #   </preference>
    #   <preference>
    #     <name>portlet-setup-use-custom-title</name>
    #     <value>true</value>
    #   </preference>
    # </portlet-preferences>
    def title
      self.properties ?
        self.properties.title : ''
    end

    # Portlet's JSR286 name.
    #
    # Requires custom migrations for PortletProperties. Defaults to portlet's portletid.
    #
    def name
      self.properties ?
        self.properties.name : self.portlet_id
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

    attr_writer :companyid

    # @companyid can be set temporarily.
    # if layout is set, its companyid is used.
    def companyid
      ( self.layout ? self.layout.companyid : @companyid
      ) or nil
    end

    # Override acts_as_resourceful. Use portlet's portletid (without INSTANCE) as the ResourceCode name.
    def resource_code(scope=4)
      ResourceCode.get({
        :companyid => self.companyid,
        :name      => self.portlet_id,
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