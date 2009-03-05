require 'test_helper'

class Tag::AssetTest < ActiveSupport::TestCase
  fixtures [
    :tagsasset, :tagsassets_tagsentries,
    :resource_, :resourcecode,
    :classname_,
    :igimage,
    :mbmessage,
    :blogsentry,
    :wikipage,
    :bookmarksentry,
    :journalarticle,
    :dlfileentry
  ]

  def setup
    @assets = Tag::Asset.all
  end

  def test_resource
    @assets.each do |asset|
      assert_not_nil asset.company

      classname = Classname.find(asset.classnameid).value
      assert_not_nil classname

      resource = asset.resource
      assert_not_nil resource

      assert_equal asset.company, resource.company

      assert_not_nil resource.liferay_class, '%s has not defined its Java class' % resource.class
      assert_equal classname,resource.liferay_class, 'Asset %i' % asset.id

      #assert_not_nil resource.content
    end
  end

  def test_label
    @assets.each do |asset|
      assert_not_nil asset.label
      assert_not_equal '', asset.label
      assert_equal asset.title, asset.label unless asset.title.empty?
    end
  end

  def test_owner
    @assets.each do |asset|
      assert_not_nil asset.owner
      assert_equal User, asset.owner.class
    end
  end

  def test_asset_types
    Tag::Asset.resource_types.each do |type|
      type.find(:all).each do |obj|
        if defined? obj.asset
          # not all messages are tagged
          next if obj.is_a?(MB::Message)
          assert_not_nil obj.asset, '%s (%i) has no Tag::Asset' % [obj.class, obj.id]

          # problems with versioned wiki and journal pages..
          unless obj.class==Wiki::Page or obj.class==Journal::Article
            assert_equal obj,obj.asset.resource
          end
        else
          STDERR.puts '%s has no asset relation' % obj.class
        end

        assert_not_nil obj.liferay_class, '%s has not defined its Java class' % obj.class
      end
    end
  end

end
