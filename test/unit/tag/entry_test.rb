require 'test_helper'

class Tag::EntryTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :TagsAsset,
    :TagsEntry,
    :TagsAssets_TagsEntries,
    :TagsProperty,
    :ClassName_
  ]

  def setup
    @tags = Tag::Entry.find :all
  end

  def test_name
    @tags.each do |x|
      assert_not_nil x.name, "#{x.id} has no name"
    end
  end

  # each tag must belong to a company
  def test_company
    @tags.each do |x|
      assert_not_nil x.company, "#{x.id} (#{x.name}) belongs to no company"
    end
  end

  def test_user
    @tags.each do |x|
      assert_not_nil x.user, "#{x.id} (#{x.name}) belongs to no user"
    end
  end

  # each asset must exist
  def test_asset
    assets = @tags.map{|x| x.assets}.uniq
    assets.each do |asset|
      assert_not_nil asset, "Reference to non-existing asset #{asset.inspect}"
    end
  end

  def test_properties
    @tags.each do |tag|
      tag.properties.each do |p|
        assert_equal tag,p.tag
      end
    end
  end

end
