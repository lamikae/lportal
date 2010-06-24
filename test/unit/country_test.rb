# encoding: utf-8
require 'test/test_helper'

class CountryTest < ActiveSupport::TestCase
  fixtures [
    :Country
  ]

  def setup
    @countries = Country.find :all
    assert @countries.size > 0, 'No countries'
  end

  def test_countries
    @countries.each do |x|
      assert_not_nil x.name
      assert_not_nil x.a2
      assert_not_nil x.a3
      assert_not_nil x.number_
      assert_not_nil x.idd_
      assert_not_nil x.active_
    end
  end

end
