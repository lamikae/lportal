class ResourceCode < ActiveRecord::Base
  set_table_name       :ResourceCode
  set_primary_key      :codeId

  public

  # belongs to Company
  def company
    Company.find(self.send(Company.primary_key))
  end

  has_many :resources,
    :foreign_key => self.primary_key

  # ResourceCode associated to an Liferay class
  #
  # Args:
  #  - :companyid
  #  - :name
  #  - :scope (defaults to 4)
  def self.find_by_liferay_class(args={})
    args.update(:scope => 4) unless args[:scope]
    ResourceCode.get(:first,
      :conditions => "#{Company.primary_key}=#{args[:companyid]} AND name='#{args[:name]}' AND scope=#{args[:scope]}")
  end

  # Finds existing or creates a new ResourceCode
  # Args:
  #  - :companyid
  #  - :name
  #  - :scope
  def self.get(args)
    conditions = []
    args.each_pair{ |k,v|
      conditions << (k==:name ?
        ("%s='%s'" % [k,v]) : ("%s=%s" % [k,v]))
    }
    #logger.debug conditions.inspect
    rc = ResourceCode.find(:first, :conditions => conditions.join(' AND '))
    unless rc
      logger.debug 'creating new ResourceCode'
      rc = self.create(args)
    end
    return rc
  end

end
