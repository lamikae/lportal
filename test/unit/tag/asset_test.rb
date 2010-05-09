# encoding: utf-8

require 'test/test_helper'

class Tag::AssetTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :Group_,
    :TagsAsset, :TagsAssets_TagsEntries,
#     :Resource_, :ResourceCode,
    :ClassName_,
    :IGImage,
    :MBMessage,
    :BlogsEntry,
    :WikiPage,
    :BookmarksEntry,
    :JournalArticle,
    :DLFileEntry,
    :Layout
  ]

  def setup
    flunk mysql_bug if defined?(mysql_bug)

    @assets = Tag::Asset.all
    # TODO: DRY up, the same creation code is in portlet test.
    unless Web::Portlet.find_by_name('asset_publisher')
      Company.all.each do |c|
        Web::Portlet.create(
          :companyid => c.id,
          :portletid => '9998'
        )
        Web::PortletProperties.create(
          :portletid => 9998,
          :name => 'asset_publisher',
          :title => ''
        )
      end
    end
    unless Web::Portlet.find_by_name('tagged_content')
      Company.all.each do |c|
        Web::Portlet.create(
          :companyid => c.id,
          :portletid => '9999'
        )
        Web::PortletProperties.create(
          :portletid => 9999,
          :name => 'tagged_content',
          :title => ''
        )
      end
    end
  end

  def test_path
    @assets.each do |asset|
      next if asset.groupid==0

      [5100, 5200].each do |build|
        Lportal::Schema.buildnumber = build

        path = asset.path
        assert_not_nil path
        assert !path.empty?
        if build==5100
          assert path[/#{asset.id}/], 'Path ”%s” does not contain asset id (%i)' % [path, asset.id]
          assert path[/tagged_content/]
        elsif build==5200
          assert path[/#{asset.resource.id}/], 'Path ”%s” does not contain asset resource id (%i)' % [path, asset.resource.id]
          assert path[/asset_publisher/]
        end
      end
    end
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

  def test_company
    @assets.each do |asset|
      assert_not_nil asset.company
    end
  end

  def test_user
    @assets.each do |asset|
      assert_not_nil asset.user, 'Asset %i has no user' % asset.id
      assert_equal User, asset.user.class
    end
  end

  def test_group
    @assets.each do |asset|
      next if asset.groupid==0
      assert_not_nil asset.group
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
