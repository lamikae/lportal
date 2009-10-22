# --
# MySQL hacks.
#
# Methods that use method_missing to get the column value cannot be aliased.
#
# Awful lot of repetition here, TODO: DRY up with metaprogramming.
#
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

class Resource < ActiveRecord::Base
  def primkey
    self.primKey
  end
  def primkey=(val)
    self.primKey=val
  end
end

class User < ActiveRecord::Base
  def screenname
    self.screenName
  end
  def screenname=(val)
    self.screenName=val
  end
end

module Web
  class LayoutSet < ActiveRecord::Base
    def virtualhost
      self.virtualHost
    end
    def virtualhost=(val)
      self.virtualHost=val
    end
    def pagecount
      self.pageCount
    end
    def pagecount=(val)
      self.pageCount=val
    end
    def privatelayout
      self.privateLayout
    end
    def privatelayout=(val)
      self.privateLayout=val
    end
  end
  class Layout < ActiveRecord::Base
    def friendlyurl
      self.friendlyURL
    end
    def friendlyurl=(val)
      self.friendlyURL=val
    end
    def privatelayout
      self.privateLayout
    end
    def privatelayout=(val)
      self.privateLayout=val
    end
    def typesettings
      self.typeSettings
    end
    def typesettings=(val)
      self.typeSettings=val
    end
  end
end

class User < ActiveRecord::Base
  def defaultuser
    self.defaultUser
  end
end


# define companyid
[Company,User,Account,Group,Web::LayoutSet,Web::Layout,Role,ResourceCode].each do |cl|
  cl.class_eval {
    def companyid
      self.companyId
    end
    def companyid=(val)
      self.companyId=val
    end
  }
end

# define groupid
[Web::LayoutSet,Web::Layout].each do |cl|
  cl.class_eval {
    def groupid
      self.groupId
    end
    def groupid=(val)
      self.groupId=val
    end
  }
end

# define classnameid
[Group,Role].each do |cl|
  cl.class_eval {
    def classnameid
      self.classNameId
    end
    def classnameid=(val)
      self.classNameId=val
    end
  }
end

# define classpk
[Group,Role].each do |cl|
  cl.class_eval {
    def classpk
      self.classPK
    end
    def classpk=(val)
      self.classPK=val
    end
  }
end


# used to flunk tests
def mysql_bug
  'FIXME: this is a known to fail with MySQL'
end