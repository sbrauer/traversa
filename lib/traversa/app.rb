require 'sinatra/base'

module Traversa
  class App < Sinatra::Base

    # FIXME: support other HTTP verbs (with special handling for PUT)
    get '/*' do
      names = params[:splat].first.split('/')
      root = root_factory(request)
      resource = traverse(names, root)
      if resource.respond_to? :get
        resource.get(self, request, params)
      else
        raise Sinatra::NotFound
      end
    end

    # Subclasses of App should override to return a root Resource.
    def root_factory(request)
      Root.new
    end

    def traverse(names, context)
      params[:subpath] = names.dup
      name = names.shift
      return context unless name && (context.respond_to? :child)
      new_context = context.child(name)
      if new_context
        traverse(names, new_context)
      else
        context
      end
    end

    def resource_path(resource, subpath=[])
      if resource.parent
        resource_path(resource.parent, [resource.name] + subpath)
      else
        "/#{subpath.join('/')}#{'/' unless subpath.empty?}"
      end
    end

  end
end
