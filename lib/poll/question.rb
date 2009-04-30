module Poll
  class Question < ActiveRecord::Base

    belongs_to :company,
      :foreign_key => Company.primary_key

    belongs_to :user,
      :foreign_key => User.primary_key

    belongs_to :group,
      :foreign_key => Group.primary_key

  end
end
