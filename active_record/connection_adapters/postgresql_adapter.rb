module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter < AbstractAdapter

      alias :original_quote_column_name :quote_column_name

      def quote_column_name(name) #:nodoc:
        original_quote_column_name(name).downcase
      end

    end
  end
end
