require 'test/test_helper'

class ImageTest < ActiveSupport::TestCase
  fixtures [
    :Image,
    :IGImage
  ]

  def setup
    @images = Image.find :all
  end

  def test_type
    @images.each do |x|
      assert_not_nil x.type_, "#{x.id} type is null"
    end
  end

  def test_dimensions
    @images.each do |x|
      assert_not_nil x.width
      assert_not_nil x.height
    end
  end

  def test_size
    @images.each do |x|
      assert_not_nil x.size_, "#{x.id} size is null"
      assert x.size_ > 0, "#{x.id} size is not positive"
    end
  end

  def test_gallery
    @images.each do |x|
      igs = IG::Image.find(:first, :conditions => "smallimageid=#{x.id} OR largeimageid=#{x.id} OR custom1imageid=#{x.id} OR custom2imageid=#{x.id}")
      assert !igs.nil?, "#{x.id} is not referenced in any igimage"
    end
  end

end
