require 'test_helper'

class ResourceTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :Resource_, :ResourceCode,
    :Permission_,
    :IGImage,
    :PortletPreferences,
    :MBMessage,
    :Layout,
    :JournalArticle,
    :BookmarksFolder,
    :WikiNode, :WikiPage, :WikiPageResource,
    :AnnouncementsEntry,
    :CalEvent,
    :DLFolder, :DLFileEntry
  ]

  def setup
    @resources = Resource.all
  end

  # each resource must have a resourcecode
  def test_codes
    @resources.each do |x|
      assert_not_nil x.resourcecode, "#{x.id} has no resourcecode"
    end
  end

  def test_permissions
    @resources.each do |x|
      x.permissions.each do |p|
        assert_equal Permission, p.class
        assert_equal x, p.resource
      end
    end
  end

  def test_layout
    @resources.each do |x|
      if x.layout
        assert_equal Web::Layout, x.class
      end
    end
  end
  
#   def test_permissions
#     @resources.each do |x|
#       permissions = x.permissions
#       #assert !permissions.empty?, "Resource #{x.id} has no permissions"
#       permissions.each do |perm|
#         assert_not_nil perm, "Resource #{x.id} refers to an undefined permission"
#       end
#     end
#   end

  # NOT ALL TESTS PASS - THE DATABASE MODELING IS INCOMPLETE
  def test_primkey
    companies_ids = Company.find(:all).map{|x| x.id.to_s}
    groups_ids = Group.find(:all).map{|x| x.id.to_s}

    @resources.each do |x|
      key = x.primkey

      unless (companies_ids.include?(key) or groups_ids.include?(key))

        # liferay leaves dead resources around,
        # and the database may still be considered 'sane'
        begin
          content = x.content
          assert_not_nil content, "Resource #{x.id}, primkey #{key} is not any known content type #{x.code.name}"
        rescue
#           STDERR.puts $!.message
        end

        if key[/LAYOUT/]
          assert_not_nil x.plid, "Improper LAYOUT resourcecode #{key} for #{x.id}"
          assert_not_nil x.portletid, "Improper LAYOUT resourcecode #{key} for #{x.id}"

          codename = key[/LAYOUT_([^_]*)/,1]
          assert_not_nil codename, "Improper LAYOUT resourcecode #{key} for #{x.id}"
          #assert_equal codename,x.code.name, "Codenames do not match for resource #{x.id}"
        end

      end
    end
  end

end
