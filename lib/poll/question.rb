module Poll
  class Question < ActiveRecord::Base
    set_table_name       :pollsquestion
    set_primary_key      :questionid

    # com.liferay.portlet.polls.model.PollsQuestion
    def liferay_class
      'com.liferay.portlet.polls.model.PollsQuestion'
    end

    belongs_to :company,
      :foreign_key => 'companyid'

    belongs_to :user,
      :foreign_key => 'userid'

    belongs_to :group,
      :foreign_key => 'groupid'

  end
end
