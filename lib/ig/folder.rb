# Image Gallery
module IG
  class Folder < ActiveRecord::Base
    set_table_name       :igfolder
    set_primary_key      :folderid

    # com.liferay.portlet.imagegallery.model.IGFolder
    def liferay_class
      'com.liferay.portlet.imagegallery.model.IGFolder'
    end

    belongs_to :company,
      :foreign_key => 'companyid'

    belongs_to :user,
      :foreign_key => 'userid'

    belongs_to :group,
      :foreign_key => 'groupid'


  end
end
