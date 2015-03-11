# A trivial demo Traversa app.
# Root resource has a sub-resource "foo" ("/foo")
# which in turn has a sub-resource "bar" ("/foo/bar").

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'traversa'

class Demo < Traversa::App
  def root_factory(request)
    Root.new
  end
end

class Root < Traversa::Root
  def child(name)
    if name == 'foo'
      Foo.new(name, self)
    end
  end
end

class Foo < Traversa::Resource
  def child(name)
    if name == 'bar'
      Bar.new(name, self)
    end
  end
end

class Bar < Traversa::Resource
end
