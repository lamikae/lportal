# encoding: utf-8

module Wiki
  class PageResource < ActiveRecord::Base

    # association to WikiNode
    belongs_to :node,
      :class_name  => "Wiki::Node",
      :foreign_key => "nodeid"

    has_one :asset,
      :class_name  => 'Tag::Asset',
      :foreign_key => 'classpk'

  end
end
