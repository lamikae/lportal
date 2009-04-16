# TODO: rename to Blog::Entry
class BlogPost < ActiveRecord::Base

  belongs_to :company,
    :foreign_key => 'companyid'

  # association to user
  belongs_to :user,
    :foreign_key => 'userid'
  alias :writer :user
  alias :owner  :user

  # association to group
  belongs_to :group,
    :foreign_key => 'groupid'
  alias :community :group

  has_one :asset,
    :class_name  => 'Tag::Asset',
    :foreign_key => 'classpk'

#   # URL path to this BlogPost.
#   # Layout should contain the 'tagged_content' portlet.
#   def path(layout)
#     basic_asset_url(content_viewer)
#   end

end
