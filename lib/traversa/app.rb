require 'sinatra/base'

module Traversa
  class App < Sinatra::Base

    get     ('/*') { handle_request }
    post    ('/*') { handle_request }
    put     ('/*') { handle_request }
    delete  ('/*') { handle_request }
    patch   ('/*') { handle_request }
    options ('/*') { handle_request }

    def handle_request
      request_method = request.request_method.downcase.to_sym
      request_method = :get if request_method == :head

      names = params[:splat].first.split('/')
      resource, subpath = traverse(root(request), names)

      if subpath.empty?
        handle_found(resource, request_method)
      else
        handle_missing(resource, request_method, subpath)
      end
    end

    def handle_found(resource, request_method)
      if resource.respond_to? request_method
        resource.send(request_method, self, request, params)
      else
        405
      end
    end

    def handle_missing(resource, request_method, subpath)
      missing_method = "#{request_method}_missing".to_sym
      if resource.respond_to? missing_method
        resource.send(missing_method, self, request, params, subpath)
      else
        missing_status_code(request_method)
      end
    end

    # Subclasses of App should override to return an app-specific root Resource.
    def root(request)
      Root.new
    end

    # Subclasses of App could override to return different status codes.
    def missing_status_code(request_method)
      request_method == :delete ? 204 : 404
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

    # Returns array of parent resources for the given resource.
    def resource_parents(resource)
      if resource.parent
        [resource.parent] + resource_parents(resource.parent)
      else
        []
      end
    end

    # Returns path (starting with "/")
    def resource_path(resource, subpath=[])
      resources = resource_parents(resource).reverse + [resource]
      names = resources.map { |r| r.name } + subpath
      if names.length == 1
        '/'
      else
        names.join('/')
      end
    end

    # Returns full url (protocol, host, port, etc)
    def resource_url(resource, subpath=[])
      "FIXME"
    end

  end
end
