module Web
  # LayoutSets contain individual Layout s. They are either private or public.
  class LayoutSet < ActiveRecord::Base
    set_table_name       :layoutset
    set_primary_key      :layoutsetid

    # com.liferay.portal.model.LayoutSet
    def liferay_class
      'com.liferay.portal.model.LayoutSet'
    end

    def initialize(params)
      super(params)
      self.logo             ||= false
      self.logoid           ||= 0
      self.pagecount        ||= 0
      self.themeid          ||= ''
      self.colorschemeid    ||= '01'
      self.wapthemeid       ||= 'mobile'
      self.wapcolorschemeid ||= '01'
      self.css              ||= ''
      self.virtualhost      ||= ''

      self.save
    end

    public

    belongs_to :group,
      :foreign_key => 'groupid'

    belongs_to :company,
      :foreign_key => 'companyid'

    def is_public?
      !self.privatelayout
    end

    def is_private?
      self.privatelayout
    end

    def has_logo?
      self.logo
    end

    def layouts
      Web::Layout.find(:all, :conditions => "groupid=#{self.groupid} AND privatelayout=#{self.privatelayout}" )
    end

    # lookup the path prefix for this LayoutSet
    def url_prefix
      return '/web' if self.is_public?
      _class = (
        self.group.classnameid==0 ?
        Group : Classname.model(Classname.find(self.group.classnameid).value)
      )
      if _class == User
        return '/user' #if self.is_private?
        #return '/web'

      elsif _class == Group
        return '/group' #if self.is_private?
        #return '/web'

      else
        logger.debug 'FIXME: ' + _class
        return nil
      end
    end

    #?
    #   has_one :resource,
    #     :foreign_key => 'primkey'

  end
end