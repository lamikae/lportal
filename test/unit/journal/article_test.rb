require 'test_helper'

class Journal::ArticleTest < ActiveSupport::TestCase
  fixtures [
    :journalarticle,
    :journalarticleresource,
    :tagsasset
  ]

  def setup
    @articles = Journal::Article.all
  end

  # each article must belong to a company
  def test_company
    @articles.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  def test_group
    @articles.each do |x|
      assert_not_nil x.group, "#{x.id} belongs to no group!"
    end
  end

  def test_owner
    @articles.each do |x|
      assert_not_nil x.owner, "#{x.id} belongs to no user!"
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


end
