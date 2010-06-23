# encoding: utf-8

class Phone < ActiveRecord::Base

  belongs_to :company, :foreign_key => Company.primary_key
  belongs_to :user,    :foreign_key => User.primary_key

  def initialize(params)
    super(params)

    self.createdate   ||= Time.now
    self.modifieddate = Time.now
    self.company      = self.user.company
    self.username     ||= self.user.fullname
    self.classnameid  = Classname.find_by_value(Contact.liferay_class).id
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