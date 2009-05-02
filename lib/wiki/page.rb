module Wiki
  class Page < ActiveRecord::Base

    belongs_to :company,
      :foreign_key => Company.primary_key

    # association to WikiNode
    belongs_to :node,
      :class_name  => 'Wiki::Node',
      :foreign_key => Wiki::Node.primary_key

    belongs_to :user,
      :foreign_key => User.primary_key
    alias :writer :user

    belongs_to :resource,
      :class_name => 'Wiki::PageResource',
      :foreign_key => Wiki::PageResource.primary_key

    def asset
      self.resource.asset
    end

  end
end
