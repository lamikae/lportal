require 'test/test_helper'

class Journal::TemplateTest < ActiveSupport::TestCase
  fixtures [
    :Company,
    :User_,
    :Group_,
    :JournalTemplate
  ]

  def setup
    @templates = Journal::Template.all
  end

  def test_company
    @templates.each do |x|
      assert_not_nil x.company
    end
  end

  def test_group
    @templates.each do |x|
      assert_not_nil x.group
    end
  end

  def test_user
    @templates.each do |x|
      assert_not_nil x.user
    end
  end

end
