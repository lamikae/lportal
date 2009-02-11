module IG
  # Image gallery image
  class Image < ActiveRecord::Base
    set_table_name       :igimage
    set_primary_key      :imageid

    # com.liferay.portlet.imagegallery.model.IGImage
    def liferay_class
      'com.liferay.portlet.imagegallery.model.IGImage'
    end

    belongs_to :company,
      :foreign_key => 'companyid'

    belongs_to :user,
      :foreign_key => 'userid'

    has_one :asset,
      :class_name  => 'Tag::Asset',
      :foreign_key => 'classpk'

    belongs_to :folder,
      :class_name  => 'IG::Folder',
      :foreign_key => 'folderid'

    def large
      ::Image.find self.largeimageid
    end

    def small
      ::Image.find self.smallimageid
    end

  end
end
