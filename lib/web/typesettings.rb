module Web
  # Typesettings for portlets. Used in Web::Layout.
  class Typesettings

    attr_accessor :template_id
    
    # accepts a Hash, where the key tells the column
    # { 1 => [Web::PortletPreferences, ...], 2 => [...], ... }
    attr_accessor :portlets

    # Takes either existing raw typesettings string (to be parsed) or a Hash, when clean Typesettings is created.
    def initialize(params={})
      @portlets = {}
      if params.is_a?(String)
        self.read(params)
      else
        self.columns = (params[:columns] || 2)
      end
    end

    # Parses raw typesettings String into an object (self).
    def read(raw)
      _x = raw.split(/\n/)
      #puts _x.inspect

      template_id = _x.find{|z| z[/layout-template-id.*/]}
      if template_id
        _x.delete_at(_x.index(template_id))
        @template_id = template_id[/=(.*)/,1]
      end

      _x.each do |col|
        @portlets[col[/-(.)=/,1].to_i] = col[/=(.*)/,1].split(/,/)
      end
    end

    # Choose the number of columns in the Layout
    def columns=(nr)
      @template_id = (
        case nr
        when 1
          '1_column'
        when 2
          '2_columns_ii'
        else
          raise 'Invalid column number'
        end
      )
    end

    # Output String
    def to_s
      s = ''
      s << "layout-template-id=%s\n" % @template_id if @template_id
      s << self.parse
      return s
    end

    # Accepts a PortletName as the first parameter,
    # the second parameter acceps a Hash {:column => nr} where nr is the column to place the portlet.
    def method_missing(method, *args, &block)
      begin
        portlet = Web::PortletName.find_by_name(method.to_s)
        return nil unless portlet

        column = 1
        if args.any?
          if args.first[:column]
            column = args.first[:column]
          end
        end

        @portlets.update(column => [portlet.portletid])

      rescue
        STDERR.puts $!.message
        STDERR.puts 'Have you installed Caterpillar?'
        return nil
      end
      self
    end

    # Formulates the typesettings columns string for portlets
    def parse
      columns = []
      @portlets.each_pair do |column,portlets|
        # handle several portlet types
        portletids = []
        portlets.each do |p|
          if p.is_a?(String)
            portletids << p
          elsif (p.is_a?(Web::Portlet) or p.is_a?(Web::PortletPreferences))
            portletids << p.portletid
          else
            raise 'Unknown portlet type %s' % p.class
          end
        end
        columns << "column-%i=%s," % [column, portletids.join(",")]
      end
      columns.join("\n")
    end

    # Does this Typesettings include this portlet?
    # Params:
    #  - portlet (either name as String, or Web::PortletName)
    def include?(args)
      if args.is_a?(String)
        p = Web::PortletName.find_by_name args
      elsif args.is_a?(Web::PortletName)
        p = args
      else
        raise 'Invalid input class: %s' % args.class
      end

      #!@portlets_s[/[=,]#{p.portletid},/].nil?

      # this may be handy if columns are needed
      #_x = @portlets.find{|k,v| v.include?(p.portletid)}
      #return false if _x.nil?
      #column = _x.first[0] 
      #return true

      @portlets.any?{|k,v| v.include?(p.portletid)}
    end

  end
end