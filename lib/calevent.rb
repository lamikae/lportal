class Calevent < ActiveRecord::Base
  set_table_name       :calevent
  set_primary_key      :eventid

  # com.liferay.portlet.calendar.model.CalEvent
  def liferay_class
    'com.liferay.portlet.calendar.model.CalEvent'
  end

  belongs_to :company,
    :foreign_key => 'companyid'

  belongs_to :user,
    :foreign_key => 'userid'

  belongs_to :group,
    :foreign_key => 'groupid'


end
