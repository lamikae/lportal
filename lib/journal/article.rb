module Journal
  class Article < ActiveRecord::Base

    belongs_to :company,
      :foreign_key => Company.primary_key

    belongs_to :group,
      :foreign_key => Group.primary_key

    # association to user
    belongs_to :user,
      :foreign_key => User.primary_key
    alias :owner :user

    belongs_to :resource,
      :class_name => 'Journal::ArticleResource',
      :foreign_key => 'resourceprimkey'

    def asset
      self.resource.asset
    end

#     # association to assets
#     has_and_belongs_to_many  :assets,
#       :join_table              => 'tagsassets_tagsentries',
#       :foreign_key             => 'entryid',
#       :association_foreign_key => 'assetid'

    # Path to this article. See Tag::Asset#path.
    def path
      self.asset.path
    end

  end

end
