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

class Contact < ActiveRecord::Base
  def firstname
    self.firstName
  end
  def lastname
    self.lastName
  end
end

class Counter < ActiveRecord::Base
  def currentid
    self.currentId
  end
end

class Group < ActiveRecord::Base
  def classnameid
    self.classNameId
  end
  def classnameid=(val)
    self.classNameId=val
  end
  def classpk
    self.classPK
  end
  def classpk=(val)
    self.classPK=val
  end
  def creatoruserid=(val)
    self.creatorUserId=val
  end
  def friendlyurl
    self.friendlyURL
  end
  def friendlyurl=(val)
    self.friendlyURL=val
  end
  def livegroupid
    self.liveGroupId
  end
  def livegroupid=(val)
    self.liveGroupId=val
  end
  def parentgroupid
    self.parentGroupId
  end
  def parentgroupid=(val)
    self.parentGroupId=val
  end
  def typesettings
    self.typeSettings
  end
  def typesettings=(val)
    self.typeSettings=val
  end
end

class Release < ActiveRecord::Base
  def buildnumber
    self.buildNumber
  end
end

class User < ActiveRecord::Base
  def screenname
    self.screenName
  end
end

module Web
  class LayoutSet < ActiveRecord::Base
    def virtualhost
      self.virtualHost
    end
    def pagecount
      self.pageCount
    end
    def privatelayout
      self.privateLayout
    end
  end
  class Layout < ActiveRecord::Base
    def privatelayout
      self.privateLayout
    end
  end
end

class User < ActiveRecord::Base
  def defaultuser
    self.defaultUser
  end
end


# define companyid
[Company,User,Account,Group,Web::LayoutSet].each do |cl|
  cl.class_eval {
    def companyid
      self.companyId
    end
  }
end

# define groupid
[Web::LayoutSet,Web::Layout].each do |cl|
  cl.class_eval {
    def groupid
      self.groupId
    end
  }
end
