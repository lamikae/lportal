class Resource < ActiveRecord::Base
  set_table_name       :resource_
  set_primary_key      :resourceid

  public

  belongs_to :resourcecode,
    :class_name => 'ResourceCode',
    :foreign_key => 'codeid'
  alias :code :resourcecode

  has_many :permissions,
    :foreign_key => 'resourceid'

  belongs_to :articleresource,
    :class_name => 'Journal::ArticleResource',
    :foreign_key => 'primkey'

  belongs_to :layout,
    :class_name => 'Web::Layout',
    :foreign_key => 'primkey'

  def plid
    self.primkey[/([0-9]*)_LAYOUT_(.*)/,1]
  end

  def portletid
    self.primkey[/([0-9]*)_LAYOUT_(.*)/,2]
  end

  # finds content for primkey
  def content
    key = self.primkey

    _class = Classname.model(self.code.name)
    if _class
      _class.find key

    else
      if key[/LAYOUT/]
        Web::PortletPreferences.find(:first, :conditions => "plid=#{self.plid} AND portletid='#{self.portletid}'" )
      else
  #         unless groups_ids.include? key
        STDERR.puts "fixme: #{self.code.name} (#{key})"
        return nil
  #         end
      end
    end
  end

end

