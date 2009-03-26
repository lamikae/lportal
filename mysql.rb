# --
# MySQL hacks.
#
# Methods that use method_missing to get the column value cannot be aliased.
# ++

class Company < ActiveRecord::Base
  def virtualhost
    self.virtualHost
  end
  def webid
    self.webId
  end
end

class Counter < ActiveRecord::Base
  def currentid
    self.currentId
  end
end

class Release < ActiveRecord::Base
  def buildnumber
    self.buildNumber
  end
end

module Web
  class LayoutSet < ActiveRecord::Base
    def virtualhost
      self.virtualHost
    end
  end
end

class User < ActiveRecord::Base
  def defaultuser
    self.defaultUser
  end
end

[Company,User,Account].each do |cl|
  cl.class_eval {
    def companyid
      self.companyId
    end
  }
end