require 'test_helper'

class Journal::ArticleImageTest < ActiveSupport::TestCase
  fixtures [
    :journalarticle,
    :journalarticleresource,
    :tagsasset
  ]
end