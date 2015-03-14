# An minimal example Resource.
module Traversa
  class Resource

    attr_reader :name, :parent

    def initialize(name, parent)
      @name = name
      @parent = parent
    end

    def child(name)
      nil
    end

    def get(app, request, params)
      app.content_type 'text/plain'
      [
        "Hello! My name is #{name.inspect}.",
        "",
        "parent: #{parent.inspect}",
        "resource_path: #{app.resource_path(self)}",
        "resource_url: #{app.resource_url(self)}",
        "params: #{params.inspect}",
        "request: #{request.inspect}"
      ].join("\n")
    end

  end
end
