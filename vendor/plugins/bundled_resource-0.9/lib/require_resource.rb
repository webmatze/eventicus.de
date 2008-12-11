# RequireResource v.1.1 by Duane Johnson
# Makes inclusion of javascript and stylesheet resources easier via automatic or explicit
# calls.  e.g. require_javascript 'popup' is an explicit call.
#
# Note that this can easily be turned in to a helper on its own.
module RequireResource
  def stylesheet_auto_link_tags
    ensure_resource_is_initialized(:stylesheet)
    autorequire(:stylesheet)
    @stylesheets.uniq.inject("") do |buffer, css|
      buffer << stylesheet_link_tag(css) + "\n    "
    end
  end

  def javascript_auto_include_tags
    ensure_resource_is_initialized(:javascript)
    autorequire(:javascript)
    @javascripts.uniq.inject("") do |buffer, js|
      buffer << javascript_include_tag(js) + "\n    "
    end
  end

  def require_javascript(script)
    require_resource(:javascript, script)
  end

  def require_stylesheet(sheet)
    require_resource(:stylesheet, sheet)
  end
  
  protected
    # Adds resources such as stylesheet or javascript files to the corresponding array of
    # resources that will be 'required' by the layout. The +resource_type+ is either
    # :javascript or :stylesheet. The +extension+ is optional, and should normally correspond
    # with the resource type, e.g. 'css' for :stylesheet and 'js' for :javascript.
    def autorequire(resource_type, extension = nil)
      extensions = {:stylesheet => 'css', :javascript => 'js'}
      path = "#{RAILS_ROOT}/public/#{resource_type.to_s.pluralize}/" 
      candidates = [ "#{controller.controller_name}",
                     "#{controller.controller_name}_#{controller.action_name}" ]

      for candidate in candidates
        if FileTest.exist?("#{path}/#{candidate}.#{extension || extensions[resource_type]}")
          require_resource(resource_type, candidate)
        end
      end
    end

    # Adds a resource (e.g. a javascript) to the appropriate array (e.g. @javascripts)
    # ONLY if the resource is not already included.
    def require_resource(type, name)
      variable = type.to_s.pluralize
      new_resource_array = (instance_variable_get("@#{variable}") || []) | [name]
      instance_variable_set("@#{variable}", new_resource_array)
    end

    # Ensures that a resource array (e.g. @javascripts) is not nil--uses [] if so
    def ensure_resource_is_initialized(type)
      variable = type.to_s.pluralize
      new_resource_array = (instance_variable_get("@#{variable}") || [])
      instance_variable_set("@#{variable}", new_resource_array)      
    end
end