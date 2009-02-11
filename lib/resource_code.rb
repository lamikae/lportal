class ResourceCode < ActiveRecord::Base
  set_table_name       :resourcecode
  set_primary_key      :codeid

  public

  belongs_to :company,
    :foreign_key => "companyid"

  has_many :resources,
    :foreign_key => "codeid"

  # ResourceCode associated to an Liferay class
  #
  # Args:
  #  - :companyid
  #  - :name
  #  - :scope (defaults to 4)
  def self.find_by_liferay_class(args={})
    args.update(:scope => 4) unless args[:scope]
    ResourceCode.find(:first,
      :conditions => "companyid=#{args[:companyid]} AND name='#{args[:name]}' AND scope=#{args[:scope]}")
  end

end
