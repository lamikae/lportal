# encoding: utf-8

require 'test/test_helper'

class DlFileTest < ActiveSupport::TestCase
  fixtures [:DLFileEntry, :DLFolder, :Company, :User_, :TagsAsset]

  def setup
    @files = DlFile.all
  end

  def test_folder
    @files.each do |dlf|
      assert_not_nil dlf.folder
    end
  end

  def test_company
    @files.each do |dlf|
      assert_not_nil dlf.company
    end
  end

  def test_user
    @files.each do |dlf|
      assert_not_nil dlf.user
    end
  end

  def test_asset
    @files.each do |dlf|
      assert_not_nil dlf.asset
    end
  end

  def test_path
    @files.each do |dlf|
      assert_not_nil dlf.path
      assert dlf.path[/#{dlf.folderid}/]
      assert dlf.path[/#{dlf.name}/]
    end
  end
end
