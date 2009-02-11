module Announcement
  class Delivery < ActiveRecord::Base
    set_table_name       :announcementsdelivery
    set_primary_key      :deliveryid

    belongs_to :company,
      :foreign_key => 'companyid'

    belongs_to :user,
      :foreign_key => 'userid'

  end
end