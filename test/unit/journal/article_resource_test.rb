require 'test_helper'

class Journal::ArticleResourceTest < ActiveSupport::TestCase
  fixtures [
    :Company,
#     :User_,
    :Group_,
    :JournalArticle,
    :JournalArticleResource,
    :TagsAsset
  ]

  def setup
    @resources = Journal::ArticleResource.all
  end

  def test_group
    @resources.each do |x|
      assert_not_nil x.group, "#{x.id} belongs to no group!"
    end
  end

  def test_article
    @resources.each do |x|
      assert_not_nil x.article, "#{x.id} has no article!"
    end
  end

  def test_asset
    @resources.each do |x|
      assert_not_nil x.asset, "#{x.id} has no asset!"
    end
  end


end
