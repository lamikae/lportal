require 'test_helper'

class IG::ImageTest < ActiveSupport::TestCase
  fixtures  :igimage, :igfolder

  def setup
    @igimages = IG::Image.all
  end

  def test_company
    @igimages.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  def test_user
    @igimages.each do |x|
      assert_not_nil x.user, "#{x.id} belongs to no user!"
    end
  end

  def test_folder
    @igimages.each do |x|
      assert_not_nil x.folder
    end
  end

end
