require 'test_helper'

class ResourceCodeTest < ActiveSupport::TestCase
  fixtures [
    :resource_, :resourcecode,
  ]

  def setup
    @resourcecodes = ResourceCode.all
  end

  # each resourcecode must belong to a company
  def test_company
    @resourcecodes.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no companies"
    end
  end

  # each resourcecode must have a scope
  def test_scope
    @resourcecodes.each do |x|
      assert_not_nil x.scope, "#{x.id} has no scope"
    end
  end

  def test_rigidity
    # each resource must exist!
    resources = @resourcecodes.map{|x| x.resources}.uniq
    resources.each do |r|
      assert_not_nil r
    end
  end
end
