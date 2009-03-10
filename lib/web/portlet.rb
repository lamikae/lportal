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
        @preferences = Web::PortletPreferences.create({:portlet => self})
      end
      return @preferences
    end

    attr_writer :preferences

    # All instances of a specific portlet. See also preferences.
    def instances
      unless @instances
        @instances = Web::PortletPreferences.find_all_by_portletid(self.portletid)
      end
      return @instances
    end

    # Various static properties of the portlet instance and the portlet in general.
    # Requires custom migrations for PortletProperties.
    # The tables within are filled by Caterpillar, since it knows the location of the
    # portlet XML files.
    def properties
      unless @properties
        @properties = Web::PortletProperties.find_by_portletid(self.portletid)
      end
      return @properties
    end

    # The default title string that is displayed.
    #
    # Requires custom migrations for PortletProperties. Defaults to an empty string.
    #
    # PortletPreferences may override this, see PortletPreferences#title.
    #
    def title
      self.properties ?
        self.properties.title : ''
    end

    # name = portletid
    def name
      self.portletid
    end

    def is_active?
      self.active_
    end

    # Is the portlet instanceable? This is defined in the XML configuration.
    # Requires custom migrations for PortletProperties.
    #
    # Defaults to true.
    def instanceable?
      return @instanceable if !@instanceable.nil? # test value
      self.properties ?
        self.properties.instanceable : true
    end

    # for testing and debugging
    attr_writer :instanceable

  end
end