class Counter < ActiveRecord::Base
  set_table_name       :counter
  set_primary_key      :name

  # Increments the counter
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
