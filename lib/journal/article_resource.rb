module Journal
  class ArticleResource < ActiveRecord::Base
    set_table_name       :journalarticleresource
    set_primary_key      :resourceprimkey

    # com.liferay.portlet.journal.model.JournalArticleResource
    def liferay_class
      'com.liferay.portlet.journal.model.JournalArticleResource'
    end

    belongs_to :group,
      :foreign_key => 'groupid'

    has_one :asset,
      :class_name  => 'Tag::Asset',
      :foreign_key => 'classpk'

    #     belongs_to :article,
    #       :class_name => 'Journal::Article',
    #       :foreign_key => 'articleid'

    # verbose has_one :article, as articleid does not refer the primkey of Journal::Article
    def article
      Journal::Article.find_by_articleid self.articleid
    end

  end
end