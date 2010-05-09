# encoding: utf-8

module ActiveRecord
  # Alter fixture typecase.
  module TestFixtures
    module ClassMethods

      alias :original_fixtures :fixtures

      # On PostgreSQL, use downcase table names
      def fixtures(*table_names)
        case ActiveRecord::Base.connection.adapter_name
        when 'PostgreSQL'
          table_names = table_names.flatten.collect{ |n| n.to_s.downcase }
        end
        original_fixtures(table_names)
      end

    end
  end
end