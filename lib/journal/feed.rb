module Journal
  class Feed < ActiveRecord::Base
    set_table_name       :journalfeed
    set_primary_key      :id_

    # com.liferay.portlet.journal.model.JournalFeed
    def liferay_class
      'com.liferay.portlet.journal.model.JournalFeed'
    end

    belongs_to :company,
      :foreign_key => 'companyid'

    belongs_to :user,
      :foreign_key => 'userid'

    belongs_to :group,
      :foreign_key => 'groupid'

  end
end
