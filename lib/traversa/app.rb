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
      subpath = params[:splat].first
      request_method = request.request_method.downcase.to_sym
      request_method = :get if request_method == :head
      handle_traversal_result(Traversa.traverse(root, subpath), request_method)
    end

    def handle_traversal_result(result, request_method)
      if result.success?
        handle_found(result.resource, request_method)
      else
        handle_missing(result.resource, request_method, result.subpath)
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

    # Subclasses of App may override to return different status codes.
    def missing_status_code(request_method)
      request_method == :delete ? 204 : 404
    end
  end
end
