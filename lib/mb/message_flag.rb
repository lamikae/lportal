module MB
  class MessageFlag < ActiveRecord::Base

    belongs_to :user,
      :foreign_key => User.primary_key

    belongs_to :message,
      :class_name => 'MB::Message',
      :foreign_key => MB::Message.primary_key

    def initialize(params)
      raise 'No messageid' unless params[:message] or params[:messageid]
      super(params)
    end

  end
end