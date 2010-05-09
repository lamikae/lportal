# encoding: utf-8

module ActiveRecord #:nodoc:
  # Database-specific patches.
  class Base
    class << self

    alias :original_quoted_table_name :quoted_table_name

    # For PostgreSQL, return the downcased value.
    # For other adapters use mixed case.
    def quoted_table_name
      case self.connection.adapter_name
      when 'PostgreSQL'
        original_quoted_table_name.downcase
      else
        original_quoted_table_name
      end
    end


    alias :original_define_attr_method :define_attr_method

    # For PostgreSQL, return the downcased value from the defined method (primary_key, table_name, etc)
    # For other adapters use mixed case.
    def define_attr_method(name, value=nil, &block)
      case self.connection.adapter_name

      when 'PostgreSQL'
        sing = class << self; self; end
        self.class.send :alias_method, "#{name}", name
        if block_given?
          sing.send :define_method, name, &block
        else
          # use downcased column name
          sing.class_eval "def #{name}; #{value.to_s.downcase.inspect}; end"
        end

      else
        original_define_attr_method(name, value=nil, &block)
      end
    end

    end # end class methods

    def liferay_class # :nodoc:
      self.class.liferay_class
    end

  end
end
