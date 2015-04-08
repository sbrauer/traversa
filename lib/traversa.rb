require 'traversa/version'
require 'traversa/app'

module Traversa
  # Returns a TraversalResult object with the last resource traversed to and
  # remaining subpath.
  # subpath arg should be either an array of strings or a slash-delimited string.
  # In other words, 'foo/bar/baz' and ['foo', 'bar', 'baz'] are equivalent subpath values.
  def self.traverse(resource, subpath)
    subpath = coerce_subpath(subpath)
    if resource.respond_to?(:child) && ! subpath.empty?
      child = resource.child(subpath.first)
      if child
        subpath.shift
        return traverse(child, subpath)
      end
    end
    TraversalResult.new(resource, subpath)
  end

  def self.coerce_subpath(subpath)
    if subpath.class == String
      subpath.split('/')
    else
      subpath
    end
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
