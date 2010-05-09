# encoding: utf-8

class Classname < ActiveRecord::Base

  # Returns the Class of the model for a certain Java class
  def self.model(codename)
    case codename

    # Numbers signify portlets, and can be fetched from the PortletProperties table.
    # when "56" journal_content
    # when "58" login
    # when "101" tagged_content
    # when "103" tags_compiler
    # etc...

    when 'com.liferay.portal.model.Layout'
      Web::Layout

    when 'com.liferay.portal.model.Organization'
      Organization

    when 'com.liferay.portal.model.Role'
      Role

    when 'com.liferay.portal.model.User'
      User

    when 'com.liferay.portal.model.UserGroup'
      Usergroup

    when 'com.liferay.portlet.announcements.model.AnnouncementsEntry'
      Announcement::Entry

    when 'com.liferay.portlet.blogs.model.BlogsEntry'
      BlogPost

    when 'com.liferay.portlet.bookmarks.model.BookmarksEntry'
      Bookmark::Entry

    when 'com.liferay.portlet.bookmarks.model.BookmarksFolder'
      Bookmark::Folder

    when 'com.liferay.portlet.calendar.model.CalEvent'
      Calevent

    when 'com.liferay.portlet.documentlibrary.model.DLFileEntry'
      DlFile

    when 'com.liferay.portlet.documentlibrary.model.DLFolder'
      DlFolder

    when 'com.liferay.portlet.imagegallery.model.IGFolder'
      IG::Folder

    when 'com.liferay.portlet.imagegallery.model.IGImage'
      IG::Image

    when 'com.liferay.portlet.journal.model.JournalArticle'
      Journal::Article

    when 'com.liferay.portlet.journal.model.JournalArticleResource'
      Journal::ArticleResource

    when 'com.liferay.portlet.journal.model.JournalFeed'
      Journal::Feed

    when 'com.liferay.portlet.journal.model.JournalStructure'
      Journal::Structure

    when 'com.liferay.portlet.journal.model.JournalTemplate'
      Journal::Template

    when 'com.liferay.portlet.messageboards.model.MBCategory'
      MB::Category

    when 'com.liferay.portlet.messageboards.model.MBMessage'
      MB::Message

    when 'com.liferay.portlet.polls.model.PollsQuestion'
      Poll::Question

    when 'com.liferay.portlet.wiki.model.WikiNode'
      Wiki::Node

    when 'com.liferay.portlet.wiki.model.WikiPage'
      Wiki::Page

    end
  end

end