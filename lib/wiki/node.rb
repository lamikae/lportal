module Wiki
  class Node < ActiveRecord::Base

    has_many :pages,
      :class_name  => "Wiki::Page",
      :foreign_key => "nodeid"
    alias :articles :pages

    has_many :resources,
      :class_name  => "Wiki::PageResource",
      :foreign_key => "nodeid"

  end
end
