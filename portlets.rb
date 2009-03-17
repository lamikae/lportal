module Lportal # :nodoc:
  # Liferay portlet functionalities.
  # These are accessable in Web::PortletPreferences.
  #
  # Adds +path+, that is based on the name of the portlet.
  module Portlets
    def self.included(base)
      #base.extend(ClassMethods)
    end

    include ERB::Util # for u()

    def redirect
      u('javascript: history.go(-1)')
    end

    # params:
    #   - content_id or asset
    def asset_publisher_path(params)
      asset = params[:asset]
      raise 'No asset' unless asset
      raise ('Asset %i has no resource' % asset.id) unless asset.resource
      content_id = asset.resource.id
      _path = [
        '-',
        'asset_publisher',
        self.instance_id,
        'content',
        content_id
      ].join('/')
      '%s/%s?redirect=%s' % [self.layout.path, _path, redirect]
    end

    # params:
    #   - asset_id
    def tagged_content_path(params)
      asset = params[:asset]
      raise 'No asset' unless asset

      params = "?p_p_id=#{portletid}"+\
        "&p_p_lifecycle=0"+\
        "&p_p_state=normal"+\
        "&p_p_mode=view"+\
        "&_#{portletid}_struts_action=%2Ftagged_content%2Fview_content"+\
        "&_#{portletid}_assetId=#{asset.id}"+\
        "&_#{portletid}_redirect=#{redirect}"
        # &p_p_col_id=column-1&p_p_col_count=1
      path = self.layout.path + params
    end


    # Meta method that calls the actual method that yields the path to the portlet instance.
    # In essence this is a singleton method based on the name of the portlet.
    def path(args={})
      unless self.name
        logger.warn '%s has no name' % self.class
        return ''
      end
      unless self.layout
        logger.warn 'No layout given'
        return ''
      end

      logger.debug 'Generating path for portlet %s' % self.name
      method = self.name+'_path'
      if self.respond_to?(method)
        return self.send(method, args)
      else
        # unknown path
        logger.warn 'Unknown path requested for portlet %s' % self.name
        return ''
      end
    end

  end
end
