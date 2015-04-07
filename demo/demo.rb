# A trivial single-file Traversa demo app.
# Root resource has a sub-resource "foo" ("/foo")
# which in turn has a sub-resource "bar" ("/foo/bar").

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'traversa'

# An minimal example Resource.
class Resource
  attr_reader :name, :parent

  def initialize(name, parent)
    @name = name
    @parent = parent
  end

  def get(app, request, params)
    app.content_type 'text/plain'
    [
      "Hello! My name is #{name.inspect}.",
      "",
      "parent: #{parent.inspect}",
      "resource_path: #{Traversa.resource_path(self)}",
      "resource_url: #{app.resource_url(self)}",
      "params: #{params.inspect}",
      "request: #{request.inspect}"
    ].join("\n")
  end
end

class Root < Resource
  def initialize
    @name = ''
    @parent = nil
  end

  def child(name)
    Foo.new(name, self) if name == 'foo'
  end
end

class Foo < Resource
  def child(name)
    Resource.new(name, self) if name == 'bar'
  end
end

class Demo < Traversa::App
  def root
    Root.new
  end
end
