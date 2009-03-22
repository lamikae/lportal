module ActiveRecord #:nodoc:
  # PostgreSQL fixes
  class Base
    class << self

    alias :original_quoted_table_name :quoted_table_name

    # For PostgreSQL, return the downcased value.
    def quoted_table_name
      self.connection.adapter_name=='PostgreSQL' ?
        original_quoted_table_name.downcase : original_quoted_table_name
    end


    alias :original_define_attr_method :define_attr_method

    # For PostgreSQL, return the downcased value from the defined method (primary_key, table_name, etc)
    # For other adapters use the original method.
    def define_attr_method(name, value=nil, &block)
      unless self.connection.adapter_name=='PostgreSQL'
        return original_define_attr_method(name, value=nil, &block)
      end

      sing = class << self; self; end
      self.class.send :alias_method, "#{name}", name
      if block_given?
        sing.send :define_method, name, &block
      else
        # the patch is ”downcase”
        sing.class_eval "def #{name}; #{value.to_s.downcase.inspect}; end"
      end
    end

    end
  end
end
