# Traversa
A resource-oriented microframework for Ruby built on top of [Sinatra](http://www.sinatrarb.com/).

*Status: Experimental work in progress*

## What do you mean by "resource-oriented"?
First let's clarify that by "resource" I'm referring to the "R" in URL (Uniform Resource Locator).
Traversa has the opinion that Resources are the primary abstraction that a webapp should be built around.
Sinatra and many other frameworks have a concept of routing to map the path portion
of incoming URLs to code.
Resource traversal is an alternative concept that treats the path as a way to
locate a resource in a hierarchy of resources. (The basic concept is borrowed
from the Python web framework [Pyramid](http://docs.pylonsproject.org/docs/pyramid/en/latest/narr/traversal.html).)

Consider a url like `http://www.example.com/products/books/1234/`.
Using routing, you might have a route like:
```ruby
get '/products/books/:id/' do
  # Generate a response for the given book id.
end
```

With resource traversal, you would instead have a root resource
that contains a "products" resource that contains a "books" resource
that presumably knows how to return a resource for the given book id.

Where a typical Sinatra application has routes that execute code blocks,
a Traversa application provides a factory method that returns a "root" resource (which represents the resource at the path "/").
A resource is simply a Ruby object that implements the following interface:

- `#name`: returns a string that uniquely identifies the resource within its parent resource; empty string for root resource
- `#parent`: returns a reference to the resource's parent resource; nil for the root resource
- `#child(name)`: if the resource has sub-resources, returns the sub-resource for the given `name`, or nil if there is no such sub-resource
- `#get(app, request, params)`: returns a response for a GET request
- `#post(app, request, params)`: returns a response for a POST request
- etc for other HTTP methods/verbs

Only `#name` and `#parent` are required. The others are optional. Implement only what you need
for your resource hierarchy and the HTTP methods you want to support. Generally you'll want to implement at least `#get`.

Note that a resource is not a model (in the MVC sense). It's more like a controller (but a controller that can reach out and talk to other controllers/resources in the hierarchy). How you choose to implement and use resources is up to you as the developer. If you use models (generally a good idea), your resources could manipulate models much as you would with routes/controllers, or you could have models that implement the Resource interface (hmm). Traversa has no opinion other than that you should use Resources.

Traversa splits the request path to obtain an array of names which it will attempt to traverse from the root down, asking each resource for the next child by name (using `#child`).
Traversal ends when all names from the path are consumed, or when a resource doesn't respond
to `#child`, or responds with nil (to indicate no such child resource exists).

If all path names were successfully traversed, Traversa calls the appropriate HTTP method
(`#get`, `#post`, etc) on the resource to generate a response, or it returns a 405 Method Not Allowed if the resource doesn't respond to that method.

If not all path names were successfully traversed, Traversa generally responds with a 404.
However PUT and DELETE requests are special cases. (TODO: go into detail)

### Why? Routes rock!

I'm not suggesting that resource traversal is inherently better or that routes are bad.
It's just an alternative way to structure your app.

Traversal is a natural fit for modeling urls that map to hierachical data. Instead of treating paths as opaque strings that may match route patterns, it treats the path string as a representation of an actual path.

The Resource API allows resources to "get a handle" on other resources. You can call `#parent` to walk up the hierarchy and `#child` to walk down. You can obtain the path of a resource with `Traversa.resource_path` (and you can obtain the absolute url of a resource by passing the path to the Sinatra `#url` helper method). If you've ever struggled with building urls within your application, you can imagine how handy this could be.

Your resource objects are not limited to implementing the Resource interface. You can add whatever custom methods you like. Imagine adding a `#title` method (for example, the root resource could implement it to return "Home"). You could then generate data for a crumbtrail to a given resource like so:

```ruby
Traversa.resource_lineage(resource).reverse.map do |r|
  {
    link: Traversa.resource_path(r),
    text: r.title
  }
end
```

`#resource_lineage` returns an array of the specified resource and all of its parents up to the root. Another use case is for specifying defaults on the root that can be overridden for any sub-branch of the hierarchy. For example, imagine you have some default logo on your site, but you want to override it for specific subsections. You could have the root resource respond to `#logo` with the default and other select resources respond to it as necessary. You could then determine the appropriate logo for a view with something like:

```ruby
Traversa.resource_lineage(resource).find { |r| r.respond_to?(:logo) }.logo
```

With routes, it's possible to have "holes" in your url space. Consider an app that defines routes for `/a` and for `/a/b/c` but not for `/a/b`. A user that lands on `/a/b/c` might expect that they could remove `/c` from the url to "go up a level", but will get a 404. Such a thing is not possible when modeling your web app as a hierarchy of resources (unless the resource at `/a/b` doesn't implement the `#get` method, or implements it such that it intentionally returns a 404 response).

Traversal and routing can also co-exist; you could have routes for some requests and then fallback to traversal when no route matches. A hybrid approach like this would let you choose the best approach on a case-by-case basis, or it could be used while migrating a legacy route-based app to traversal. (TODO: document HOWTO)

Since Resources are just Ruby objects, you can unit test them by instantiating one and testing the subset of Resource methods that you need it to support.
