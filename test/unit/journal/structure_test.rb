require 'test/test_helper'

class Journal::StructureTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :Group_,
    :JournalStructure
  ]

  def setup
    @strucs = Journal::Structure.all
  end

  def test_company
    @strucs.each do |x|
      assert_not_nil x.company
    end
  end

  def test_group
    @strucs.each do |x|
      assert_not_nil x.group
    end
  end

  def test_user
    @strucs.each do |x|
      assert_not_nil x.user
    end
  end

end
