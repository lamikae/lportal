require 'test_helper'

class PhoneTest < ActiveSupport::TestCase
  fixtures [
    :company,
    :user_,
    :phone,
    :contact_,
    :classname_,
    :listtype
  ]

  def setup
    @phones = Phone.all
  end

  def test_phones
    @phones.each do |phone|
      assert_not_nil phone.company
      assert_not_nil phone.user
      assert_equal phone.company, phone.user.company

      classnameid = Classname.find_by_value('com.liferay.portal.model.Contact').id
      assert_equal classnameid, phone.classnameid

      assert_equal phone.user.contact.id, phone.classpk

#       mobile = ListType.find_by_name('Mobile').id
#       assert_equal mobile, phone.typeid
    end
  end

end