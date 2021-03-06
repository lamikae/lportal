# encoding: utf-8

class Resource < ActiveRecord::Base

  belongs_to :resourcecode,
    :class_name => 'ResourceCode',
    :foreign_key => 'codeid'
  alias :code :resourcecode

  has_many :permissions,
    :foreign_key => self.primary_key

  belongs_to :articleresource,
    :class_name => 'Journal::ArticleResource',
    :foreign_key => 'primkey'

  belongs_to :layout,
    :class_name => 'Web::Layout',
    :foreign_key => 'primkey'

  # Finds existing or creates a new Resource. TODO: DRY to resourceful
  # Args Hash:
  #  - :codeid
  #  - :primkey
  def self.get(args)
    conditions = []
    args.each_pair{ |k,v|
      conditions << (k==:primkey ?
        ("%s='%s'" % [k,v]) : ("%s=%s" % [k,v]))
    }
    #puts conditions.inspect
    r = self.find(:first, :conditions => conditions.join(' AND '))
    unless r
      logger.debug 'creating new %s' % self.class
      r = self.create(args)
    end
    r.reload
  end

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

