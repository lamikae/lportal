# encoding: utf-8

require 'test/test_helper'

class Announcement::EntryTest < ActiveSupport::TestCase
  fixtures :Company, :User_, :AnnouncementsEntry

  def setup
    @announcements = Announcement::Entry.all
  end

  def test_company
    @announcements.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  def test_user
    @announcements.each do |x|
      assert_not_nil x.user, "#{x.id} belongs to no user!"
    end
  end

#   def test_asset
#     @announcements.each do |x|
#       assert_not_nil x.asset
#     end
#   end

end
