module Web
  # Not all portlets are necessarily saved in the database.
  class Portlet < ActiveRecord::Base
    set_table_name       :portlet
    set_primary_key      :id_

    public

    belongs_to :company,
      :foreign_key => "companyid"

    # PortletPreferences model (@preferences)
    # This Web::Portlet instance may have several "instances of itself", each of which are stored
    # in PortletPreferences.
    attr_accessor :preferences

    # Portlet should belong to a group!
    attr_accessor :group

    # Actions for Permissions.
    def self.actions
      %w{
        CONFIGURATION
        VIEW
      }
    end

    # Creates a portlet instance with preferences.
    def initialize(params={})
      prefs = {:portlet => self}
      prefs.update(:instantiate => (params[:instantiate].nil? ? true : params.delete(:instantiate)))

      super(params)
      self.active_ = true if self.active_.nil?

      @preferences = Web::PortletPreferences.new(prefs)

      self
    end
    
    # name = portletid
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

    # all resources
    def resources
  #     Resource.find_by_primkey(self.primkey)
  #     Resource.find(:all, :conditions => "primkey='#{self.primkey}'")
      resources = []
      ResourceCode.find(:all, :conditions => "name='#{portletid}'").each do |rc|
        resources << Resource.find(:all, :conditions => "codeid='#{rc.id}'")
      end

      return resources.flatten
    end

    # resource by codeid
    def resource(rc)
      case rc.scope
      when 1
        primkey = self.companyid
      when 2
        raise 'instance does not belong to a group' unless @group
        primkey = @group.id
      when 4
        primkey = self.preferences.primkey
      else
        raise 'unknown scope'
      end
      Resource.get({
        :codeid  => rc.codeid,
        :primkey => primkey
      })
    end

    # when creating new instances, it is common to find a resource code, and a resource that matches the code.
    # if they cannot be found from the database, they are created.
    # this method takes care of all that.
    def find_resource(args)
      rc = self.resource_code(args[:scope])
      self.resource(rc)
    end

    def is_active?
      self.active_
    end
    
    # ResourceCode associated to this instance (and scope)
    def resource_code(scope=4)
      ResourceCode.get({
        :companyid => self.companyid,
        :name => self.name,
        :scope => scope
      })
    end
    
  end
end