module MB
  class MessageFlag < ActiveRecord::Base
    set_table_name       :mbmessageflag
    set_primary_key      :messageflagid

    # com.liferay.portlet.messageboards.model.MBMessageFlag
    def liferay_class
      'com.liferay.portlet.messageboards.model.MBMessageFlag'
    end

    belongs_to :user,
      :foreign_key => 'userid'

    belongs_to :message,
      :class_name => 'MB::Message',
      :foreign_key => 'messageid'

  end
end