module Lportal
  # The schema version of the Liferay database.
  # The +buildnumber+ class variable is set when lportal is loaded,
  # and is a Fixnum of form 5201, for example.
  # the +version+ method is a String of form '5.2.x'.
  class Schema
    @@BUILD = nil
    @@VERSION = nil

    def self.buildnumber
      @@BUILD
    end

    # setter for buildnumber
    def self.buildnumber=(val)
      @@BUILD = val
    end

    def self.version
      return nil if @@BUILD.nil?
      @@VERSION = '%s.%s.%d' % @@BUILD.to_s.scan(/(.)(.)(..)/).flatten
    end

    def self.version=(val)
      @@VERSION = val
    end

  end
end


