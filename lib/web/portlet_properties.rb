module Web # :nodoc:
  # This table is not in the original lportal database.
  # This is created by a ActiveRecord migration and contains metadata about portlets.
  class PortletProperties < ActiveRecord::Base
    set_table_name       :portletproperties

    # Returns a portlet from a random company unless @companyid is set.
    def portlet
      unless @portlet
        conditions = ["portletid='#{self.portletid}'"]
        conditions << "companyid=#{@companyid}" if @companyid
        @portlet = Web::Portlet.find(:first, :conditions => conditions.join(' AND '))
        unless @portlet
          # create
          p = Web::Portlet.create(
            :portletid => self.portletid
          )
          if @companyid
            p.companyid = @companyid
            p.save
          end
          @portlet = p.reload
        end
      end
      return @portlet
    end

    # @companyid can be set temporarily.
    attr_accessor :companyid

  end
end
