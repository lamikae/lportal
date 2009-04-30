require 'test_helper'

class DlFolderTest < ActiveSupport::TestCase
  fixtures [:DLFileEntry, :DLFolder, :Company, :User_, :Group_]

  def setup
    @folders = DlFolder.all
  end

  def test_files
    @folders.each do |dlf|
      dlf.files.each do |f|
        assert_not_nil f
      end
    end
  end

  def test_company
    @folders.each do |dlf|
      assert_not_nil dlf.company
    end
  end

  def test_user
    @folders.each do |dlf|
      assert_not_nil dlf.user
    end
  end

  def test_group
    @folders.each do |dlf|
      assert_not_nil dlf.group
    end
  end
end
