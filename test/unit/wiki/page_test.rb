# encoding: utf-8

require 'test/test_helper'

class Wiki::PageTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :WikiPage,
    :WikiNode,
    :WikiPageResource,
    :TagsAsset,
    :ClassName_
  ]

  def setup
    @pages = Wiki::Page.all
    flunk 'No wiki pages to test' unless @pages.any?
  end

  def test_company
    @pages.each do |x|
      assert_not_nil x.company
    end
  end

  def test_node
    @pages.each do |x|
      assert_not_nil x.node
    end
  end

  def test_user
    @pages.each do |x|
      assert_not_nil x.user
    end
  end

  def test_resource
    @pages.each do |x|
      assert_not_nil x.resource
    end
  end

  def test_asset
    @pages.each do |x|
      assert_not_nil x.asset
    end
  end

end
