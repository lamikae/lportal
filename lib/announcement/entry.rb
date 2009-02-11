module Announcement
  class Entry < ActiveRecord::Base
    set_table_name       :announcementsentry
    set_primary_key      :entryid

    belongs_to :company,
      :foreign_key => 'companyid'

    belongs_to :user,
      :foreign_key => 'userid'

#     has_one :asset,
#       :foreign_key => 'classpk'


  end
end
