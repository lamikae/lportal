module Web # :nodoc:
  # Portlets can be included onto a Layout. Portlets are in instantiated per se, when one is
  # inserted on a Layout, PortletPreferences is created. This instance (from Rails' point-of-view),
  # may be instantiated or not, from its POV. Instantiation in this sense means that each PortletPreferences
  # may be customised per-session.
  #
  # Caterpillar can gather this information from the XML files, see its documentation.
  #
  class Portlet < ActiveRecord::Base
    set_table_name       :portlet
    set_primary_key      :id_

    public

    # com.liferay.portal.model.Portlet
    def liferay_class
      'com.liferay.portal.model.Portlet'
    end

    belongs_to :company,
      :foreign_key => "companyid"

    # Creates a portlet instance with preferences.
    def initialize(params={})
      super(params)
      self.roles ||= ''
      self.active_ = true if self.active_.nil?

      self
    end

    # PortletPreferences for this instance (@preferences)
    #
    # This Web::Portlet instance may have several "instances of itself", each of which are stored
    # in PortletPreferences. Each of these are unique rows in the database,
    # and these are accessible through the 'instances' association.
    #
    # PortletPreferences are created when the Portlet is added to a Layout.
    # Its portletid, on the other hand, depends on whether this portlet is instanceable.
    def preferences
      unless @preferences
        @preferences = Web::PortletPreferences.create(
          {:portlet => self}
        )
      end
      return @preferences
    end

    attr_writer :preferences

    def instances
      Web::PortletPreferences.find_all_by_portletid self.portletid
    end

    # name = portletid
    def name
      self.portletid
    end

    # primkey in resource_ table
    def primkey(plid)
      STDERR.puts 'DEPRECATED -- use %s.preferences.primkey' % self
      "#{plid}_LAYOUT_#{self.portletid}"
    end

    def is_active?
      self.active_
    end

    # This portlet setting is not in the database.
    # This method exists to make it possible to call this method from Layout.
    # Caterpillar re-defines this method and returns the value in the XML configuration.
    #
    # Defaults to true.
    def instanceable?
      return @instanceable if !@instanceable.nil? # test value
      self.properties.instanceable
    end

    # for testing and debugging
    attr_writer :instanceable

  end
end