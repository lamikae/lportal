# encoding: utf-8

require 'test/test_helper'

class AssetTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :TagsAsset,
    :Resource_, :ResourceCode,
    :BlogsEntry,
    :User_,
    :Group_
  ]

  def setup
    @posts = BlogPost.all
    flunk 'No posts to test' unless @posts.any?
  end

  def test_company
    @posts.each do |p|
      assert_not_nil p.company
    end
  end

  def test_user
    @posts.each do |p|
      assert_not_nil p.user
    end
  end

  def test_group
    @posts.each do |p|
      assert_not_nil p.group
    end
  end

  def test_asset
    @posts.each do |p|
      assert_not_nil p.asset
    end
  end

#   def test_resource
#     @posts.each do |p|
#       assert_not_nil p.resource
#     end
#   end

#   def test_path
#     @posts.each do |p|
#       assert_not_nil p.path
#     end
#   end

end