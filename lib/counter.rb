# encoding: utf-8

class Counter < ActiveRecord::Base

  # Increments the counter +name+ by +value+.
  def self.increment(name, value)
    if name.is_a?(Symbol)
      name = (
        case name
        when :permission
          'com.liferay.portal.model.Permission'
        when :resource
          'com.liferay.portal.model.Resource'
        end
      )
    end
    c = self.find(name)
    c.currentid += value
    c.save
  end

end
