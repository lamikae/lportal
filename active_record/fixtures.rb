# Alter fixture typecase.
class Test::Unit::TestCase #:nodoc:
  class << self
  
  alias :orig_fixtures :fixtures
  
  def fixtures(*table_names) # :nodoc:
    case ActiveRecord::Base.connection.adapter_name
    when 'PostgreSQL'
      table_names = table_names.flatten.collect{ |n| n.to_s.downcase }
    end
    orig_fixtures(table_names)
  end
  end
end