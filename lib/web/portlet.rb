# encoding: utf-8

module Web # :nodoc:
  # Portlets can be included onto a Layout. Portlets are not instantiated per se; when one is
  # inserted on a Layout, PortletPreferences is created. This instance (from ActiveRecord's point-of-view),
  # may be instantiated or not, from Liferay's POV. Instantiation in this sense means that each PortletPreferences
  # may have session-based customization.
  #
  # Caterpillar can gather this information from the Liferay XML files, see its documentation.
  #
  class Portlet < ActiveRecord::Base

    belongs_to :company,
      :foreign_key => Company.primary_key

    # Creates a portlet instance with preferences.
    def initialize(params={})
      super(params)
      self.roles ||= ''
      self.active_ = true if self.active_.nil?

      self
    end


    # Searches from PortletProperties.
    # Returns nil unless one is found. Returns a Portlet if the properties are found.
    def self.find_by_name(name)
      pp = Web::PortletProperties.find_by_name(name)
      unless pp
        logger.warn 'Portlet by name was not found -- are portletproperties up-to-date?'
        return nil
      end
      pp.portlet
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

    # Portlet's JSR286 name.
    #
    # Requires custom migrations for PortletProperties. Defaults to portletid.
    #
    def name
      self.properties ?
        self.properties.name : self.portletid
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