module Lportal # :nodoc:
  # Liferay portlet functionalities.
  # These are accessable in Web::PortletPreferences.
  module Portlets
    def self.included(base)
      #base.extend(ClassMethods)
      puts 'extended by %s' % self.class
    end

    include ERB::Util # for u()

    def redirect
      u('javascript: history.go(-1)')
    end

    def asset_publisher_path(params)
      raise 'No layout given' unless self.layout
      content_id = params[:content_id]
      raise 'No content_id' unless content_id
      _path = [
        '-',
        'asset_publisher',
        self.instance_id,
        'content',
        content_id
      ].join('/')
      '%s/%s?redirect=%s' % [self.layout.path, _path, redirect]
    end

    def tagged_content_path(params)
      raise 'No layout given' unless self.layout
      content_id = params[:content_id]
      raise 'No content_id' unless content_id
      portletid = self.portlet_id

      params = "?p_p_id=#{portletid}"+\
        "&p_p_lifecycle=0"+\
        "&p_p_state=normal"+\
        "&p_p_mode=view"+\
        "&_#{portletid}_struts_action=%2Ftagged_content%2Fview_content"+\
        "&_#{portletid}_assetId=#{content_id}"+\
        "&_#{portletid}_redirect=#{redirect}"
        # &p_p_col_id=column-1&p_p_col_count=1
      path = self.layout.path + params
    end


    # meta method that calls the actual method that yields the path to the portlet instance.
    def path(args={})
      unless self.name
        logger.warn '%s has no name' % self.class
        return ''
      end
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