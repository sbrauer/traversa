# A trivial single-file Traversa demo app.
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'traversa'

class HelloResource
  attr_reader :name, :parent

  def initialize(name, parent)
    @name = name
    @parent = parent
  end

  def get(app, request, params)
    "<h1>Hello #{name}!</h1>"
  end
end

class Root
  def initialize
    @name = ''
    @parent = nil
  end

  def child(name)
    HelloResource.new(name, self)
  end

  def get(app, request, params)
    '<h1>Hello world!</h1><p>Try adding a path element to the url... <a href="/Sam">like this</a></p>'
  end
end

class Demo < Traversa::App
  def root
    Root.new
  end
end
