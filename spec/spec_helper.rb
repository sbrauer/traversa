$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'traversa'

class SampleResource
  attr_accessor :name, :parent

  def initialize(name, parent)
    @name = name
    @parent = parent
  end
end

class SampleResourceWithChildren < SampleResource
  attr_accessor :children

  def child(name)
    @children[name]
  end
end
