require 'test_helper'

class DlFileTest < ActiveSupport::TestCase
  fixtures [:dlfileentry, :company, :user_, :tagsasset]

  def setup
    @files = DlFile.all
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
    end
  end




end
