# Traversa
Resource traversal for [Sinatra](http://www.sinatrarb.com/).

## What the heck is resource traversal?
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
for your resource hierarchy and the HTTP methods you want to support.

Note that a resource is not a model (in the MVC sense). How you choose to implement and use resources is up to you as the developer. If you use models, your resources could manipulate models much as you would with routes, or you could have models that implement the Resource interface. Traversa has no opinion other than that you should use Resources.

### Why? Routes rock!

I'm not suggesting that resource traversal is inherently better or that routes are bad.
It's just an alternative way to structure your app.

Traversal is a natural fit for modeling urls that map to hierachical data. Instead of treating paths as opaque strings that may match route patterns, it treats the path string as a representation of an actual path.
It acknowledges that URLs (Uniform Resource Locators) are about locating resources by making the concept of "resources" the fundamental building block of your web app.

With routes, it's possible to have "holes" in your url space. Consider an app that defines routes for `/a` and for `/a/b/c` but not for `/a/b`. A user that lands on `/a/b/c` might expect that they could remove `/c` from the url to "go up a level", but will get a 404. Such a thing is not possible when modeling your web app as a hierarchy of resources (unless the resource at `/a/b` doesn't implement the `#get` method, or implements it such that it intentionally returns a 404 response).

The resource traversal approach also automates the process of generating URLs for resources. (TODO: implement a `#resource_url(resource)` method; just have `#resource_path(resource)` now). Given a resource, your app can "get a handle" on other resources by calling `#parent` to walk up the hierarchy or `#child(name)` to walk down.

Traversal and routing can also co-exist; you could have routes for some requests and then fallback to traversal when no route matches. A hybrid approach like this would let you choose the best approach on a case-by-case basis, or it could be used while migrating a legacy route-based app to traversal. (TODO: document HOWTO)
