import Foundation
import OWOWKit

/// A protocol for types that can return elements, usually from a "page"-based API.
public protocol Paginator: class {
    /// The `Element` type the paginator paginates.
    associatedtype Element
    
    /// Returns a `Future` that will resolve to the requested `Element`.
    func get(index: Int) -> Future<Element>
    
    /// Returns a `Future` that will resolve to the requested page.
    func get(page: Int) -> Future<[Element]>
    
    /// Registers a new closure that is executed when the amount of elements is known.
    ///
    /// - parameter handler: The handler to execute when the amount of elements is known.
    /// - returns: A closure that cancels the handler from being called.
    func onCount(_ handler: @escaping (Int?) -> Void) -> (() -> Void)
    
    /// Starts fetching the given `indices`, if necessary.
    ///
    /// - parameter indices: The indices that should be prefetched.
    func prefetch(indices: [Int])
    
    /// The criteria used with the paginator.
    var criteria: CriteriaSet { get set }
    
    /// Signals a reload to the paginator.
    func reload()
}
