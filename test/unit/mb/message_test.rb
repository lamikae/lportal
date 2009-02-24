require 'test_helper'

class MB::MessageTest < ActiveSupport::TestCase
  fixtures [
    :mbcategory,
    :mbdiscussion,
    :mbmessage,
    :mbthread,
    :mbstatsuser,
    :mbmessageflag,
    :classname_,
    :group_,
    :user_
  ]

  def setup
    @messages = MB::Message.all
  end

  def test_new_rootmsg
    user = User.first
    category = MB::Category.first
    subject = random_string
    body = random_string

    msg = MB::Message.create(:category => category, :user => user, :subject => subject, :body => body)

    assert_equal subject, msg.subject
    assert_equal body, msg.body

    assert_not_nil msg.flag
    assert_equal 1, msg.flag.flag

    category.reload
    assert_equal category, msg.category
    assert_in_delta Time.now, category.lastpostdate.getlocal, 1.0


    thread = MB::Thread.find(:first,
      :conditions => "categoryid=#{category.id} AND rootmessageid=#{msg.id}")
    assert_not_nil thread
    assert_equal thread, msg.thread
    assert_equal 1, thread.messagecount
    assert_equal user.id, thread.lastpostbyuserid
    assert_in_delta Time.now, thread.lastpostdate.getlocal, 1.0


    stats = MB::StatsUser.find(:first, :conditions => "groupid=#{category.group.id} AND userid=#{user.id}")
    assert_not_nil stats
    assert_equal 1, stats.messagecount
    assert_in_delta Time.now, stats.lastpostdate.getlocal, 1.0


    classnameid = Classname.find_by_value(msg.liferay_class).id
    assert_not_nil RatingsStats.find(:first, :conditions => "classnameid=#{classnameid} AND classpk=#{msg.id}")

    assert_not_nil SocialActivity.find(:first,
      :conditions => "userid=#{user.id} AND classnameid=#{classnameid} AND classpk=#{msg.id}")

    assert_not_nil Tag::Asset.find(:first,
      :conditions => "userid=#{user.id} AND classnameid=#{classnameid} AND classpk=#{msg.id}")

    rc = msg.resource_code(1)
    assert_not_nil rc
    assert_not_nil Resource.find(:first,
      :conditions => "codeid=#{rc.id} AND primkey='#{msg.companyid}'")

    rc = msg.resource_code(2)
    assert_not_nil rc
    assert_not_nil Resource.find(:first,
      :conditions => "codeid=#{rc.id} AND primkey='#{category.group.id}'")

    rc = msg.resource_code(4)
    assert_not_nil rc
    resource = Resource.find(:first,
      :conditions => "codeid=#{rc.id} AND primkey='#{msg.id}'")
    assert_not_nil resource

    msg.class.actions.each do |actionid|
      p = Permission.find(:first,
        :conditions => "companyid=#{msg.companyid} AND actionid='#{actionid}' AND resourceid=#{resource.id}")
      assert_not_nil p
      assert user.permissions.include?(p)
    end
  end

  def test_new_reply
    parent = MB::Message.first
    category = parent.category
    assert_not_nil category

    user = User.first
    subject = random_string
    body = random_string

    thread = parent.thread
    assert_not_nil thread
    thread_messagecount = thread.messagecount

    stats = MB::StatsUser.find(:first, :conditions => "groupid=#{category.groupid} AND userid=#{user.id}")
    stats_messagecount = (stats.nil? ? 0 : stats.messagecount)

    msg = MB::Message.create(
      :parent => parent,
      :user => user,
      :subject => subject,
      :body => body
    )

    assert_equal subject, msg.subject
    assert_equal body, msg.body
    assert_equal parent, msg.parent

    assert_not_nil msg.flag
    assert_equal 1, msg.flag.flag


    category.reload
    assert_equal category, msg.category
    assert_in_delta Time.now, category.lastpostdate.getlocal, 1.0


    thread.reload
    assert_equal thread, msg.thread
    assert_equal thread_messagecount+1, thread.messagecount
    assert_equal user.id, thread.lastpostbyuserid
    assert_in_delta Time.now, thread.lastpostdate.getlocal, 1.0


    stats = MB::StatsUser.find(:first, :conditions => "groupid=#{category.groupid} AND userid=#{user.id}")
    assert_not_nil stats
    assert_equal stats_messagecount+1, stats.messagecount
    assert_in_delta Time.now, stats.lastpostdate.getlocal, 1.0


    # COPY ratingsstats (statsid, classnameid, classpk, totalentries, totalscore, averagescore) FROM stdin;
    # +10316	10071	10314	0	0	0

    classnameid = Classname.find_by_value(msg.liferay_class).id
    assert_not_nil RatingsStats.find(:first, :conditions => "classnameid=#{classnameid} AND classpk=#{msg.id}")

    assert_not_nil SocialActivity.find(:first,
      :conditions => "userid=#{user.id} AND classnameid=#{classnameid} AND classpk=#{msg.id}")

    assert_not_nil Tag::Asset.find(:first,
      :conditions => "userid=#{user.id} AND classnameid=#{classnameid} AND classpk=#{msg.id}")

    rc = msg.resource_code(4)
    assert_not_nil rc
    resource = Resource.find(:first,
      :conditions => "codeid=#{rc.id} AND primkey='#{msg.id}'")
    assert_not_nil resource

    msg.class.actions.each do |actionid|
      p = Permission.find(:first,
        :conditions => "companyid=#{msg.companyid} AND actionid='#{actionid}' AND resourceid=#{resource.id}")
      assert_not_nil p
      assert user.permissions.include?(p)
    end

  end

  def test_company
    @messages.each do |x|
      assert_not_nil x.company, "#{x.id} belongs to no company"
    end
  end

  def test_user
    @messages.each do |x|
      assert_not_nil x.user, "#{x.id} belongs to no user!"
    end
  end

  def test_category
    @messages.each do |x|
      assert_not_nil x.category, "#{x.id} belongs to no category!"
    end
  end

  def test_thread
    @messages.each do |x|
      assert_not_nil x.thread, "#{x.id} belongs to no thread"
      if x.parentmessageid == 0 then
        assert x.thread.rootmessageid == x.id, "Discrepancy between thread #{x.thread.id} rootmessageid #{x.thread.rootmessageid} and message #{x.id}"
      end
    end
  end

  def test_parent
    @messages.each do |x|
      unless x.parentmessageid == 0 then
        assert_not_nil x.parent, "#{x.id} refers to parent message #{x.parentmessageid} which does not exist"
      else
        # there must be a root thread with this message
        assert MB::Thread.find(:all).map{
          |t| t.rootmessageid }.include?(x.id), "Message #{x.id} appears not to belong to any thread"
      end
    end
  end

  def test_asset
    @messages.each do |x|
      assert_nothing_raised { x.asset }
    end
  end

end
