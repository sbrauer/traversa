require 'traversa/version'
require 'traversa/app'

module Traversa
  # Returns a TraversalResult object with the last resource traversed to and
  # an array of names leftover after the last successful traversal.
  def self.traverse(resource, names)
    if resource.respond_to?(:child) && ! names.empty?
      child = resource.child(names.first)
      if child
        names.shift
        return traverse(child, names)
      end
    end
    TraversalResult.new(resource, names)
  end

  # Returns array of parent resources for the given resource.
  def self.resource_parents(resource)
    if resource.parent
      [resource.parent] + resource_parents(resource.parent)
    else
      []
    end
  end

  # Returns array of resource and its parent resources.
  def self.resource_lineage(resource)
    [resource] + resource_parents(resource)
  end

  # Returns path (starting with "/")
  def self.resource_path(resource, subpath=[])
    names = resource_lineage(resource).reverse.map { |r| r.name } + subpath
    if names.length == 1
      '/'
    else
      names.join('/')
    end
  end

  class TraversalResult
    attr_accessor :resource, :subpath

    def initialize(resource, subpath)
      @resource = resource
      @subpath = subpath
    end

    def success?
      subpath.empty?
    end
  end
end
