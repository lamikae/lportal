require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  def setup
    @images = Image.find :all
  end

  def test_type
    @images.each do |x|
      assert !x.type_.nil?, "#{x.id} type is null"
    end
  end

  def test_dimensions
    @images.each do |x|
      assert !x.width.nil? && !x.height.nil?, "#{x.id} has no width && height"
    end
  end

  def test_size
    @images.each do |x|
      assert !x.size_.nil?, "#{x.id} size is null"
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
