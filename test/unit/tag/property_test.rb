require 'test_helper'

class Tag::PropertyTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :TagsEntry,
    :TagsProperty
  ]

  def setup
    @properties = Tag::Property.find :all
  end

  def test_company
    @properties.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no companies"
    end
  end

  def test_user
    @properties.each do |x|
      assert_not_nil x.user, "#{x.id} belongs to no user"
    end
  end

  def test_tags
    @properties.each do |p|
      assert p.tag.properties.include?(p)
    end
  end

  def test_rigidity
    # each asset must exist
    tags = @properties.map{|x| x.tag}.uniq
    tags.each do |tag|
      assert_not_nil tag, "Reference to non-existing tag #{tag.inspect}"
    end
  end
end
