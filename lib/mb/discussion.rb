module MB
  class Discussion < ActiveRecord::Base
    set_table_name       :mbdiscussion
    set_primary_key      :discussionid

    # com.liferay.portlet.messageboards.model.MBDiscussion
    def liferay_class
      'com.liferay.portlet.messageboards.model.MBDiscussion'
    end

    belongs_to :thread,
      :class_name => "MB::Thread",
      :foreign_key => "threadid"

  end
end