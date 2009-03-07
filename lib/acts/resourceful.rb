module Acts #:nodoc:
  module Resourceful
    def self.included(base)
      base.extend(ClassMethods)
    end
  #--
    # This +acts_as+ extension provides the capabilities for sorting and reordering a number of objects in a list.
    # The class that has this specified needs to have a +position+ column defined as an integer on
    # the mapped database table.
    #
    # Todo list example:
    #
    #   class TodoList < ActiveRecord::Base
    #     has_many :todo_items, :order => "position"
    #   end
    #
    #   class TodoItem < ActiveRecord::Base
    #     belongs_to :todo_list
    #     acts_as_list :scope => :todo_list
    #   end
    #
    #   todo_list.first.move_to_bottom
    #   todo_list.last.move_higher
  #++
    module ClassMethods
    #--
      # Configuration options are:
      #
      # * +column+ - specifies the column name to use for keeping the position integer (default: +position+)
      # * +scope+ - restricts what is to be considered a list. Given a symbol, it'll attach <tt>_id</tt>
      #   (if it hasn't already been added) and use that as the foreign key restriction. It's also possible
      #   to give it an entire string that is interpolated if you need a tighter scope than just a foreign key.
      #   Example: <tt>acts_as_list :scope => 'todo_list_id = #{todo_list_id} AND completed = 0'</tt>
    #++
      def acts_as_resourceful(options = {})

        class_eval <<-EOV
          include Acts::Resourceful::InstanceMethods

          def acts_as_resourceful_class
            ::#{self.name}
          end
        EOV
      end
    end

    # All the methods available to a record that has had <tt>acts_as_resourceful</tt> specified.
    module InstanceMethods

      # ResourceCode associated to this instance (and scope)
      def resource_code(scope=4)
        ResourceCode.get({
          :companyid => self.companyid,
          :name      => self.liferay_class,
          :scope     => scope
        })
      end

      # Default primkey in scope 2. Override in the model if necessary.
      def scope2_primkey
        raise 'instance does not belong to a group' unless self.group
        self.groupid
      end

      # Default primkey in scope 4. Override in the model if necessary.
      def scope4_primkey
        self.id
      end

      # resource by codeid
      def resource(rc)
        case rc.scope
        when 1
          primkey = self.companyid
        when 2
          primkey = self.scope2_primkey
        when 4
          primkey = self.scope4_primkey
        else
          raise 'unknown scope'
        end
        Resource.get({
          :codeid  => rc.codeid,
          :primkey => primkey
        })
      end

      # When creating new instances, it is common to find a resource code, and a resource that matches the code.
      # If they cannot be found from the database, they are created.
      # This method takes care of all that.
      def get_resource(args)
        rc = self.resource_code(args[:scope])
        self.resource(rc)
      end

      # Finds or creates a new Permission (and Resource + ResourceCode) for a given action
      # and a specific scope.
      def permission(actionid, scope)
        resource = get_resource(:scope => scope)
        Permission.get(
          :companyid  => self.companyid,
          :actionid   => actionid,
          :resourceid => resource.id
        )
      end

    end
  end
end
