# encoding: utf-8

require 'test/test_helper'

class Journal::ArticleTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :Group_,
    :JournalArticle,
    :JournalArticleResource,
    :TagsAsset,
    :TagsProperty,
    :Portlet
  ]

  def setup
    @articles = Journal::Article.all
  end

  def test_company
    @articles.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  def test_group
    @articles.each do |x|
      assert_not_nil x.group, "#{x.id} belongs to no group!"
      assert_equal x.group, x.resource.group
    end
  end

  def test_user
    @articles.each do |x|
      assert_not_nil x.user, "#{x.id} belongs to no user!"
    end
  end

  def test_articleid
    @articles.each do |x|
      assert_not_nil x.articleid, "#{x.id} has no articleid!"
    end
  end

  def test_resource
    @articles.each do |x|
      assert_not_nil x.resource, "#{x.id} belongs to no resource"
    end
  end

  def test_asset
    @articles.each do |x|
      assert_not_nil x.asset, "#{x.id} has no asset!"
    end
  end

  def test_path
    @articles.each do |x|
      # path is defined in Lportal::Portlets
      path = x.path
      assert_not_nil path
      assert !path.empty?

      if Lportal::Schema.buildnumber < 5200
        assert path[/_assetId=#{x.asset.id}/]
      else
        assert path[/content\/#{x.asset.resource.id}/]
      end
    end
  end

end
