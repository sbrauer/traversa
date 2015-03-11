require 'sinatra/base'

module Traversa
  class App < Sinatra::Base

    # Status code to respond with when DELETE request
    # received for a resource that can't be traversed to.
    # Subclass may want to override with 404, 200, or some other status.
    set :delete_missing_status, 204

    get     ('/*') { handle_request }
    post    ('/*') { handle_request }
    put     ('/*') { handle_request }
    delete  ('/*') { handle_request }
    patch   ('/*') { handle_request }
    options ('/*') { handle_request }

    def handle_request
      request_method = request.request_method.downcase.to_sym
      names = params[:splat].first.split('/')
      resource, subpath = traverse(root(request), names)

      unless subpath.empty?
        case request_method
        when :delete
          return settings.delete_missing_status
        when :put
          if subpath.length == 1
            params[:subpath] = subpath.first
          else
            return 404
          end
        else
          return 404
        end
      end

      if resource.respond_to? request_method
        resource.send(request_method, self, request, params)
      else
        405
      end
    end

    # Subclasses of App should override to return an app-specific root Resource.
    def root(request)
      Root.new
    end

    # Returns a tuple of the last resource traversed to and
    # an array of names leftover after the last successful traversal.
    def traverse(resource, names)
      if resource.respond_to?(:child) && ! names.empty?
        child = resource.child(names.first)
        if child
          names.shift
          return traverse(child, names)
        end
      end
      [resource, names]
    end

    # Returns path (starting with "/")
    def resource_path(resource, subpath=[])
      if resource.parent
        resource_path(resource.parent, [resource.name] + subpath)
      else
        "/#{subpath.join('/')}#{'/' unless subpath.empty?}"
      end
    end

    # Returns full url (protocol, host, port, etc)
    def resource_url(resource, subpath=[])
      "FIXME"
    end

  end
end
