module MB
  class StatsUser < ActiveRecord::Base
    set_table_name       :mbstatsuser
    set_primary_key      :statsuserid

    # com.liferay.portlet.messageboards.model.MBStatsUser
    def liferay_class
      'com.liferay.portlet.messageboards.model.MBStatsUser'
    end

    belongs_to :user,
      :foreign_key => 'userid'

    belongs_to :group,
      :foreign_key => 'groupid'

  end
end