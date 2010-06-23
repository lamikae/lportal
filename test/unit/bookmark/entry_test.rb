# encoding: utf-8

require 'test/test_helper'

class Bookmark::EntryTest < ActiveSupport::TestCase
  fixtures :Company, :User_, :BookmarksEntry, :BookmarksFolder, :TagsAsset

  def setup
    @bookmarks = Bookmark::Entry.all
    flunk 'No bookmark entries to test' unless @bookmarks.any?
  end

  def test_company
    @bookmarks.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  def test_user
    @bookmarks.each do |x|
      assert_not_nil x.user, "#{x.id} belongs to no user!"
    end
  end

  def test_folder
    @bookmarks.each do |x|
      assert_not_nil x.folder
    end
  end

  def test_asset
    @bookmarks.each do |x|
      assert_not_nil x.asset
    end
  end

end
