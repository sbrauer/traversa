require 'traversa/version'
require 'traversa/app'

module Traversa
  # Returns a TraversalResult object with the last resource traversed to and
  # remaining subpath.
  # subpath arg should be either an array of strings or a slash-delimited string.
  # In other words, 'foo/bar/baz' and ['foo', 'bar', 'baz'] are equivalent subpath values.
  def self.traverse(resource, subpath)
    unless subpath.empty?
      subpath = coerce_subpath(subpath)
      subpath.each_with_index do |name, index|
        child = get_child(resource, name)
        if child
          resource = child
        else
          return TraversalResult.new(resource, subpath.slice(index..-1))
        end
      end
    end
    TraversalResult.new(resource, nil)
  end

  # Convert String subpath to an Array.
  def self.coerce_subpath(subpath)
    if subpath.class == String
      subpath.split('/')
    else
      subpath
    end
  end

  # Return the named child resource or nil.
  def self.get_child(resource, name)
    resource.child(name) if resource.respond_to?(:child)
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
      subpath.nil?
    end
  end
end
