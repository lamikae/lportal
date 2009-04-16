require 'test_helper'

class AssetTest < ActiveSupport::TestCase
  fixtures [
    :TagsAsset,
    :Resource_, :ResourceCode,
    :BlogsEntry,
    :User_,
    :Group_
  ]

  def setup
    @posts = BlogPost.all
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