# Alter fixture typecase.
class Test::Unit::TestCase #:nodoc:
  class << self
  
  alias :original_fixtures :fixtures
  
  def fixtures(*table_names) # :nodoc:
    case ActiveRecord::Base.connection.adapter_name
    when 'PostgreSQL'
      table_names = table_names.flatten.collect{ |n| n.to_s.downcase }
    end
    original_fixtures(table_names)
  end
  end
end