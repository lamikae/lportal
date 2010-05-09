# encoding: utf-8

require 'test/test_helper'

class Bookmark::FolderTest < ActiveSupport::TestCase
  fixtures :Company, :Group_, :User_, :BookmarksEntry, :BookmarksFolder

  def setup
    @folders = Bookmark::Folder.all
    flunk 'No bookmark folders to test' unless @folders.any?
  end

  def test_company
    @folders.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  def test_group
    @folders.each do |x|
      assert_not_nil x.group
    end
  end

  def test_user
    @folders.each do |x|
      assert_not_nil x.user, "#{x.id} belongs to no user!"
    end
  end

  def test_entries
    @folders.each do |x|
      assert_not_nil x.entries
      x.entries.each do |e|
        assert_equal x, e.folder
      end
    end
  end

end
