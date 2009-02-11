require 'test_helper'

class IG::FolderTest < ActiveSupport::TestCase
  fixtures  :igimage, :igfolder

  def setup
    @folders = IG::Folder.all
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

  def test_group
    @folders.each do |x|
      assert_not_nil x.group
    end
  end

end
