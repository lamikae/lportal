require 'test_helper'

class Web::PortletTest < ActiveSupport::TestCase
  fixtures [
    :portletpreferences, :portlet, :portletitem,
    :resource_,
    :role_
  ]

  def setup
    @portlets = Web::Portlet.all
  end

  # each portlet must belong to a company
  def test_company
    @portlets.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no companies"
    end
  end

  # each role must exist
  def test_roles
    @portlets.each do |x|
      roles = x.roles.split(",")
      roles.each do |role|
        role.gsub!(/^\ *|\ *$/,"") # clean leading and trailing spaces
        assert Role.find_by_name(role), "Role \"#{role}\" does not exist"
      end
    end
  end

#   # each portlet must have a resource
#   def test_resource
#     @portlets.each do |x|
#       assert_not_nil x.resource(???), "No resource with primkey #{x.primkey}"
#     end
#   end

end
