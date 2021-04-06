import Foundation
import OWOWKit

/// A type-erased paginator.
public class AnyPaginator<Element>: Paginator {
    private let _getItem: (Int) -> Future<Element>
    private let _getPage: (Int) -> Future<[Element]>
    private let _onCount: (@escaping (Int?) -> Void) -> (() -> Void)
    private let _prefetch: ([Int]) -> Void
    private let _getCriteria: () -> CriteriaSet
    private let _setCriteria: (CriteriaSet) -> Void
    private let _reload: () -> Void
    
    public init<P: Paginator>(_ paginator: P) where P.Element == Element {
        _getItem = paginator.get(index:)
        _getPage = paginator.get(page:)
        _onCount = paginator.onCount
        _prefetch = paginator.prefetch
        _getCriteria = { paginator.criteria }
        _setCriteria = { paginator.criteria = $0 }
        _reload = paginator.reload
    }
    
    public func get(index: Int) -> Future<Element> {
        return _getItem(index)
    }
    
    public func get(page: Int) -> Future<[Element]> {
        return _getPage(page)
    }
    
    public func onCount(_ handler: @escaping (Int?) -> Void) -> (() -> Void) {
        return _onCount(handler)
    }
    
    public func prefetch(indices: [Int]) {
        return _prefetch(indices)
    }
    
    public var criteria: CriteriaSet {
        get {
            return _getCriteria()
        }
        set {
            return _setCriteria(newValue)
        }
    }
    
    public func reload() {
        _reload()
    }
}

extension Paginator {
    public func asAny() -> AnyPaginator<Element> {
        return AnyPaginator(self)
    }
}
