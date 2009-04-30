module Journal
  class ArticleResource < ActiveRecord::Base

    belongs_to :group,
      :foreign_key => 'groupid'

    has_one :asset,
      :class_name  => 'Tag::Asset',
      :foreign_key => 'classpk'

    #     belongs_to :article,
    #       :class_name => 'Journal::Article',
    #       :foreign_key => 'articleid'

    # articleid does not refer the primkey of Journal::Article
    def article
      Journal::Article.find_by_articleid self.articleid
    end

  end
end