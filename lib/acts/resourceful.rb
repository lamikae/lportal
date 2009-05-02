module Acts #:nodoc:

  # This +acts_as+ extension provides the capabilities for creating +ResourceCode+s, +Resource+s
  # and +Permission+s.
  #
  # The model needs to have defined their +liferay_class+, +companyid+, and for scope 2 resources,
  # their +groupid+. These functions may be overridden in the model itself.
  module Resourceful
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
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
      def resource_code(scope)
        ResourceCode.get({
          Company.primary_key => self.companyid,
          :name      => self.liferay_class,
          :scope     => scope
        })
      end

      # Default primkey in scope 1 is +self.companyid+. Override in the model if necessary.
      def scope1_primkey
        self.companyid
      end

      # Default primkey in scope 2 is +self.groupid+. Override in the model if necessary.
      def scope2_primkey
        raise ('Instance %s does not belong to a group' % self) unless self.group
        self.groupid
      end

      # Default primkey in scope 4 is +self.id+. Override in the model if necessary.
      def scope4_primkey
        self.id
      end

      # resource by codeid
      def resource(rc)
        case rc.scope
        when 1
          primkey = self.scope1_primkey
        when 2
          primkey = self.scope2_primkey
        when 4
          primkey = self.scope4_primkey
        else
          raise 'unknown scope'
        end
        if primkey.nil?
          logger.warn 'No primkey'
          return nil
        end
        logger.debug 'primkey: %s' % primkey
        Resource.get({
          ResourceCode.primary_key => rc.id,
          :primkey => primkey
        })
      end

      # When creating new instances, it is common to find a resource code, and a resource that matches the code.
      # If they cannot be found from the database, they are created.
      # This method takes care of all that.
      def get_resource(args)
        scope = args[:scope]
        raise 'No scope' unless scope
        logger.debug 'Get resource for %s, scope %i' % [self.liferay_class, scope]
        rc = self.resource_code(scope)
        logger.debug rc.inspect
        r = self.resource(rc)
        logger.debug r.inspect
        return r
      end

      # Finds or creates a new Permission (and Resource + ResourceCode) for a given action
      # and a specific scope.
      def permission(actionid, scope)
        resource = get_resource(:scope => scope)
        Permission.get(
          Company.primary_key => self.companyid,
          :actionid   => actionid,
          Resource.primary_key => resource.id
        )
      end

    end
  end
end
