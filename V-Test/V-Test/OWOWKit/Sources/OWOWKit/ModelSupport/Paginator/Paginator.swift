import Foundation
import Combine

/// A protocol for types that can return elements, usually from a "page"-based API.
@available(iOS 13.0.0, *)
public protocol Paginator: class {
    /// The `Element` type the paginator paginates.
    associatedtype Element
    
    /// The total amount of items.
    var count: CurrentValueSubject<Int?, Never> { get }
    
    /// Returns a `Future` that will resolve to the requested `Element`.
    func get(index: Int) -> AnyPublisher<Element, Error>
    
    /// Starts fetching the given `indices`, if necessary.
    ///
    /// - parameter indices: The indices that should be prefetched.
    func prefetch(indices: [Int])
    
    /// The criteria used with the paginator.
    var criteria: CriteriaSet { get set }
    
    /// Signals a reload to the paginator.
    func reload()
    
    /// Calls the given closure on each element in the paginator.
    func forEach(_ body: @escaping (Element) throws -> Void) -> AnyPublisher<Void, Error>
}
