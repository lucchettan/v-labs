# OWOWKit

OWOWKit is a support library for building iOS apps. By providing opinionated in-house developed features for common use cases on iOS, we are able to build iOS apps with maximum flexibility at rocket speed 🚀.

## Variants

There are two variants of OWOWKit.

- A variant for apps with support for iOS <= 12
- A variant for apps that support iOS 13 and higher (with SwiftUI and combine)

## Feature Overview

### UI

#### General extensions

Some general extensions are provided on UIKit types to make working with them easier:

- UITableView
- UIImageView
- CALayer

#### Keyboard notifications

OWOWKit provides an animation method on `UIView` for animating in perfect sync with the keyboard: `UIView.animate(withKeyboardNotification:animations:)`.

#### Constraints

OWOWKit includes a lightweight AutoLayout DSL based on operators. These operators are just syntax sugar for standard layout code that uses layout anchors.

Some examples:

**Basic usage**

```swift
// Vanilla
NSLayoutConstraint.activate([
    viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor, constant: 8)
])

// OWOWKit
NSLayoutConstraint.activate([
    viewA.leadingAnchor |=| viewB.leadingAnchor - 8
])
```

**Edges anchor**

```swift
// Vanilla
NSLayoutConstraint.activate([
    viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor, constant: 8),
    viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor, constant: -8),
    viewA.topAnchor.constraint(equalTo: viewB.topAnchor, constant: 8),
    viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor, constant: -8)
])

// OWOWKit
NSLayoutConstraint.activate(
    viewA.edgesAnchor |=| viewB.edgesAnchor - 8
)
```

#### `FeedbackTapGestureRecognizer`

`FeedbackTapGestureRecognizer` is a subclass of `UITapGestureRecognizer` that changes the alpha of it's view when it is being touched, providing basic tap feedback.

#### Support for shadows from Sketch

Because we design our apps using Sketch, having to apply a shadow with parameters from Sketch is a common operation. For this, an extension to `CALayer` is provided. The extension method accepts the same parameters as a shadow in Sketch, and under the hood, writes the correct values to the `shadowColor`, `shadowOpacity`, `shadowOffset`, `shadowRadius` and `shadowPath` properties.  

#### Table Adapters

OWOWKit includes the concept of table adapters, that greatly simplify working with instances of `UITableView`.

Table adapters implement `UITableViewDataSource` and `UITableViewDelegate` and can be composed using `CompoundTableAdapter`.

The following adapters are in the box:

- `CompoundTableAdapter`: Allows combining multiple instances of `SingleSectionTableAdapter` into a table.
- `MonolithicStaticTableAdapter`: A single section table adapter that shows a static number of cells, of only one cell type.
- `PaginatorTableAdapter`: A powerful table adapter that works with a `Paginator` type to display cells, often from a remote datasource through an API. It hides all the complexities of loading cells, data prefetching, responding to memory warnings, and more.
- `SectionHeaderTableViewAdapter`: Wraps another `SingleSectionTableAdapter`, overriding the header for the section.

### Bindable values

OWOWKit includes the `Bindable` type, a simple (compared to the likes of RxSwift) type to make values reactive. It works best with value types.

Consider the following:

```swift
let user = User(username: "Henk") // a struct
let bindableUser = Bindable(user)

let label = UILabel()
bindableUser.bind(\.username, to: label, \.text)

// Later
bindableUser.value.username = "Fred"
```

When the username of the bindable user is written, the label is automatically updated. The concept behind how this works is quite simple and easy to understand, especially when compared to RxSwift and other reactivity libraries:

- `Bindable` calls any registered observers in the `didSet` handler of it's `value`.
- Observers are just closures that are executed when the bindable value changes. Because in the example above, `User` is a value type, this includes changes in nested properties.
- The `bind` call is just syntax sugar for adding an observer that reads the given source key path from the bindable value, then writes it to the destination key path on the given object.
- `Bindable` is meant to be used for UI bindinges. As such, all observers are always called on the main thread.

Unlike other libraries, a lot of the "magic" in `Bindable` is based on key paths and plain closures. There are no special extensions to write a reactive value to a label, for example.

Along with simple bindings, OWOWKit also allows you to perform some simple mapping operations on one or more properties, making it easy to display, say, the full name of a user:

```swift
let label = UILabel()
bindableUser.map(\.firstName, \.lastname) { $0 + " " + $1 }
    .bind(to: label, \.text)
```

*Note that the above example is simplified. Normally when displaying the full name of a user, it is better to use `PersonNameFormatter` to correctly format the name.*

#### `DisposeBag`

Like RxSwift, OWOWKit `Bindable` values can be disposed in a `DisposeBag`. Unlike RxSwift, usage of a `DisposeBag` is optional.

For most bindings, you have to provide a target object. This object is weakly referenced by the `Bindable`. When the object is deallocated, the binding is also invalidated.

However, for some use cases, like reusable table view cells, you may want to deregister bindings before the target is deallocated. That's where `DisposeBag` comes in:

```swift
let disposeBag = DisposeBag()

bindableUser.bind(\.username, to: label, \.text)
    .add(to: disposeBag)
```

Then, for example, in a `UITableViewCell`:

```swift
override func prepareForReuse() {
    super.prepareForReuse()
    self.disposeBag = DisposeBag()
}
```

When the `DisposeBag` is deallocated, it automatically disposes of all of it's contents.

### Async

OWOWKit has a lightweight `Future` type, and a `Promise` type to accompany it.

Futures can be used to wrap asynchronous operations:

```swift
func someWrappedOperation() -> Future<Void> {
    let promise = Promise<Void>()
    
    someOperationWithCallback { error: Error? in
        if let error = error {
            promise.fail(error)
        } else {
            promise.succeed(())
        }
    }
    
    return promise.futureResult
}
```

The value of a future can be mapped using `map`. Futures can also be chained with other futures using `compactMap`.

### URLOperation

To perform URL requests, OWOWKit provides the `URLOperation` building class. URL operations can be scheduled on an `OperationQueue`.

```swift
func getCurrentUser() -> Future<Response<User>> {
    return URLOperation<Get, User>(url: "users/me")
        .executeOnSharedQueue()
}
```

URLOperation by default uses the value of `OWOWKit.apiURL` as prefix for all URL operations, but this behavior can be customized on a per-instance basis using the initializer.

### Paginator and URLPaginator

The `Paginator` protocol defines an API for working with an asynchronous set of values, usually from a remote datasource. 

The most commonly used implementation is `URLPaginator`. It works with a generic page format that implements the `PaginatedResponse` protocol, allowing maximum flexibility for working with different kinds of page-based API's. A `PaginatedResponse` type only needs to be able to provide a total number of elements, as well as an array of the elements themselves.

In addition to `URLPaginator`, OWOWKit also provides the type-erased `AnyPaginator`. It is recommended to build views on top of `AnyPaginator` or a generic `Paginator` type instead of on  `URLPaginator`, so you have the flexibility to change the datasource of the view (say, with a local data source) without the view needing to know this.

Transformations can also be applied to paginators using `map`, allowing for very powerful composition. For example, to receive bindable elements, one might use  `paginator.map(Bindable.init)`.

### Codable

#### JSON Coders

URLOperation works in conjunction with the provided `JSONEncodable` and `JSONDecodable` protocols to allow customising the JSON coders that are used.

The default JSON encoders and decoders can be customised using `OWOWKit.defaultJSONEncoder` and `OWOWKit.defaultJSONDecoder`.

#### Codable Colors

The `HexColor` type allows encoding and decoding of colors as hexadecimal strings, e.g. `#FFFFFF`.

### Criteria & Search

OWOWKit provides a system to support filtering requests and text-based search. At the basis of this system is the `Criteria` protocol and the `URLRequestCritera` and `SearchCriteria` that inherit from it.

One might implement a search criteria for searching users like this:

```swift
/// Criteria used to search users.
public struct UserSearchCriteria: SearchCriteria, URLRequestCriteria {
    /// Multiple search queries are not supported.
    public let multipleInstancesAllowed = false
    
    /// The search string.
    public var searchString: String
    
    /// Initialise a new `UserSearchCriteria`
    public init(searchString: String) {
        self.searchString = searchString
    }
    
    /// `URLRequestCriteria` implementation.
    public func add(to components: inout URLComponents) {
        var queryItems = components.queryItems ?? []
        queryItems += [
            URLQueryItem(name: "search", value: searchString),
            URLQueryItem(name: "searchFields", value: "full_name:like;username:like")
        ]
        components.queryItems = queryItems
    }
}
```

All the techincal details of the filtering operation, are contained in the `UserSearchCriteria` type. `URLPaginator` and `URLOperation` both provide built-in support for `URLCriteria`.


#### `SearchManager`

`SearchCriteria` can be used in conjunction with a `SearchManager` to submit search queries. Instances of `SearchManager` accept strings using the `submit` method. `SearchManager` takes care of constructing the (generic) `SearchCriteria` and writing it to a criteria set on the target key path in a debounced manner. Thus, it is only coupled to `SearchCriteria`, not to `URLPaginator` or specific types – but it *is* often used with `URLPaginator`. 

### Debounced

The `Debounced` type is a `@dynamicCallable` class that takes a time interval and closure. It works similar to debounce functions in Javascript, like the [Lodash debounce](https://lodash.com/docs#debounce) function.

Define it like this:

```swift
let myDebouncedFunction = Debounced(timeInterval: 0.5) {
    ...
}
```

Then call it like a normal function:

```swift
myDebouncedFunction()
```

### CompletionManager

`CompletionManager` can be used to simplify the implementation of callback-based API's.
