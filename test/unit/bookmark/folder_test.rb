require 'test_helper'

class Bookmark::FolderTest < ActiveSupport::TestCase
  fixtures :Company, :User_, :BookmarksEntry, :BookmarksFolder

  def setup
    @folders = Bookmark::Folder.all
  end

  def test_company
    @folders.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  def test_user
    @folders.each do |x|
      assert_not_nil x.user, "#{x.id} belongs to no user!"
    end
  end

end
