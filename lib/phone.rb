class Phone < ActiveRecord::Base
  set_table_name       :phone
  set_primary_key      :phoneid

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :user,
    :foreign_key => 'userid'

  def initialize(params)
    super(params)

    self.createdate   ||= Time.now
    self.modifieddate = Time.now
    self.companyid    = self.user.companyid
    self.username     ||= self.user.fullname
    self.classnameid  = Classname.find_by_value('com.liferay.portal.model.Contact').id
    self.classpk      = self.user.contact.id
    self.typeid       ||= ListType.find_by_name('Mobile').id
    self.primary_=true if self.primary_.nil?

    self.save
  end

  def number
    self.number_
  end

  def number=(val)
    self.number_ = val
  end

  def is_primary?
    self.primary_
  end

end