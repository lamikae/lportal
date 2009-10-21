module Web
  # LayoutSets contain individual Layout s. They are either private or public.
  class LayoutSet < ActiveRecord::Base

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
      :foreign_key => Group.primary_key

    belongs_to :company,
      :foreign_key => Company.primary_key

    def is_public?
      !self.privatelayout
    end

    def is_private?
      self.privatelayout
    end

    def has_logo?
      self.logo
    end

    # FIXME: does not work on MySQL due to 'privatelayout' in SQL
    def layouts
      return [] unless self.group
      Web::Layout.find(:all, :conditions => \
        "#{Group.primary_key}=#{self.groupid}"+\
        " AND "+\
        "privatelayout=#{self.privatelayout}" )
    end

    # lookup the path prefix for this LayoutSet
    def url_prefix
      return '' unless self.group
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
        logger.debug 'FIXME: %s' % _class
        return ''
      end
    end

    #?
    #   has_one :resource,
    #     :foreign_key => 'primkey'

  end
end