class Account < ActiveRecord::Base
end
class Address < ActiveRecord::Base
end
class BlogPost < ActiveRecord::Base
end
class Community < ActiveRecord::Base
end
class Company < ActiveRecord::Base
end
class Contact < ActiveRecord::Base
end
class Counter < ActiveRecord::Base
end
class DlFile < ActiveRecord::Base
end
class DlFolder < ActiveRecord::Base
end
class Emailaddress < ActiveRecord::Base
end
class Group < ActiveRecord::Base
end
class Image < ActiveRecord::Base
end
class LiferayClassName < ActiveRecord::Base
end
class Organization < ActiveRecord::Base
end
class Permission < ActiveRecord::Base
end
class Phone < ActiveRecord::Base
end
class Release < ActiveRecord::Base
end
class ResourceCode < ActiveRecord::Base
end
class Resource < ActiveRecord::Base
end
class Role < ActiveRecord::Base
end
class Usergroup < ActiveRecord::Base
end
class User < ActiveRecord::Base
end


module IG
  class Image < ActiveRecord::Base
  end
  class Folder < ActiveRecord::Base
  end
end


module Bookmark
  class Entry < ActiveRecord::Base
  end
  class Folder < ActiveRecord::Base
  end
end


module Journal
  class Article < ActiveRecord::Base
  end
  class ArticleResource < ActiveRecord::Base
  end
end


module MB
  class Thread < ActiveRecord::Base
  end
  class Message < ActiveRecord::Base
  end
  class Category < ActiveRecord::Base
  end
  class Discussion < ActiveRecord::Base
  end
end


module Tag
  class Asset < ActiveRecord::Base
  end
  class Entry < ActiveRecord::Base
  end
  class Property < ActiveRecord::Base
  end
end


module Web
  class LayoutSet < ActiveRecord::Base
  end
  class Layout < ActiveRecord::Base
  end
  class Portlet < ActiveRecord::Base
  end
  class PortletName < ActiveRecord::Base
  end
  class PortletPreferences < ActiveRecord::Base
  end
  class PortletProperties < ActiveRecord::Base
  end
end


module Wiki
  class Node < ActiveRecord::Base
  end
  class Page < ActiveRecord::Base
  end
  class PageResource < ActiveRecord::Base
  end
end
