module Bookmark
  class Entry < ActiveRecord::Base

    belongs_to :company,
      :foreign_key => Company.primary_key

    belongs_to :user,
      :foreign_key => User.primary_key

    belongs_to :folder,
      :class_name => 'Bookmark::Folder',
      :foreign_key => Bookmark::Folder.primary_key

    has_one :asset,
      :class_name  => 'Tag::Asset',
      :foreign_key => 'classpk'

  end
end
