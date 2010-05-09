# encoding: utf-8

# This module is a home for various classes and methods that handle portal logic, that do not belong to the database models.
module Lportal
  # Portal urls.
  class Url
    class << self

    def logout
      '/c/portal/logout'
    end

    # Control panel
    def control_panel(groupid=nil,referer_plid=nil)
      url = '/group/control_panel?'
      url << 'doAsGroupId=%i&' % groupid if groupid
      url << 'refererPlid=%i' % referer_plid if referer_plid
    end

    # Control panel manage function
    def manage(action=:my_account,referer_plid=nil)
      url = '/group/control_panel/manage?'
      portletid = Web::Portlet.find_by_name(action).portletid
      if portletid
        url << 'p_p_id=%i' % portlet_id
        url << '&p_p_lifecycle=0'
        url << '&p_p_state=maximized'
        url << '&p_p_mode=view&'
      else
        RAILS_DEFAULT_LOGGER.warn('Portlet by name %s was not found!' % action)
      end
      url << 'refererPlid=%i' % referer_plid if referer_plid
    end

    end
  end
end