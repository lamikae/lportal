# Image data
class Image < ActiveRecord::Base
  set_table_name       :image
  set_primary_key      :imageid

  # com.liferay.portal.model.Image
  def liferay_class
    'com.liferay.portal.model.Image'
  end

end
