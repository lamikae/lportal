require 'test_helper'

class Announcement::DeliveryTest < ActiveSupport::TestCase
  fixtures :Company, :User_, :AnnouncementsDelivery

  def setup
    @deliveries = Announcement::Delivery.all
  end

  def test_company
    @deliveries.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  def test_user
    @deliveries.each do |x|
      assert_not_nil x.user, "#{x.id} belongs to no user!"
    end
  end

end
