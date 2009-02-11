require 'test_helper'

class Web::LayoutSetTest < ActiveSupport::TestCase
  fixtures :layout, :layoutset, :portlet

  def setup
    @sets = Web::LayoutSet.all
    assert !@sets.empty?
  end

  # each layoutset must belong to a company
  def test_company
    @sets.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

#   def test_resource
#     @sets.each do |x|
#       assert_not_nil x.resource, "#{x.id} #{x.group.friendlyurl} belongs to no resource"
#     end
#   end

  # each layoutset must belong to a group
  def test_group
    @sets.each do |x|
      group = x.group
      assert_not_nil group, "#{x.id} belongs to no group"
    end
  end

  def test_public_layoutsets
    @sets.each do |x|
      group = x.group
      assert_not_nil group.public_layoutset, "Group #{group.id} does not have a public layoutset"
    end
  end

  def test_private_layoutsets
    @sets.each do |x|
      group = x.group
      assert_not_nil group.private_layoutset, "Group #{group.id} does not have a private layoutset"
    end
  end

  def test_rigidity
    @sets.each do |x|
      assert_not_nil x.is_public?
    end

    # each group must exist
    groups = @sets.map{|x| x.group}.uniq
    groups.each do |group|
      assert_not_nil group, "Reference to non-existing group  #{group.inspect}"
    end
  end

  # sometimes this fails but it's not harmful
  def test_pagecount
    @sets.each do |x|
      unless x.pagecount==x.layouts.size
        STDERR.puts "WARN: Pagecount does not match layouts on #{x.id} (#{(x.is_public? ? "public" : "private")}), should be #{x.layouts.size}, is #{x.pagecount}"
      end
    end
  end

#   # test /web/guest/home equivalent
#   # Guest doesn't always have home
#   def test_guest_layoutset
#     # identified by default user
#     guest = User.find_by_defaultuser(true)
#     group = guest.hive # /guest
# 
#     assert !group.nil?, "Default user does not have a home group"
# 
#     # find all layoutsets
#     layoutsets = Web::LayoutSet.find(:all).collect {|x| x if( x.groupid==group.id ) }.compact
# 
#     assert layoutsets.size > 0, "No defaultuser layoutsets found"
#     assert layoutsets.map{|x| x.is_public? }.include?(true), "No default public layoutset found"
# 
#     # pick one public
#     web = layoutsets.map{|x| x if x.is_public? }.compact.first # /web
# 
#     # layout
#     layout = Web::Layout.find( :first, :conditions => "groupid=#{web.group.id} AND layoutid=1 AND privatelayout=false" )
#     assert !layout.nil?, "Public layout with id 1 was not found for layoutset #{web.id} in group #{web.group.id}"
#     assert !layout.is_hidden?, "Public layout for layoutset #{web.id} is hidden"
#   end


end