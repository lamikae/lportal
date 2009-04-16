module IG
  class Image < ActiveRecord::Base

    belongs_to :company, :foreign_key => Company.primary_key

    belongs_to :user,    :foreign_key => User.primary_key

    has_one :asset,
      :class_name  => 'Tag::Asset',
      :foreign_key => 'classPK'

    belongs_to :folder,
      :class_name  => 'IG::Folder',
      :foreign_key => IG::Folder.primary_key

    def large
      ::Image.find self.largeimageid
    end

    def small
      ::Image.find self.smallimageid
    end

  end
end
