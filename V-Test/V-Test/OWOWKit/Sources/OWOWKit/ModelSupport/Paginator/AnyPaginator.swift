import Foundation
import Combine

/// A type-erased paginator.
@available(iOS 13.0.0, *)
public class AnyPaginator<Element>: Paginator {
    private let _get: (Int) -> AnyPublisher<Element, Error>
    private let _count: () -> (CurrentValueSubject<Int?, Never>)
    private let _prefetch: ([Int]) -> Void
    private let _getCriteria: () -> CriteriaSet
    private let _setCriteria: (CriteriaSet) -> Void
    private let _reload: () -> Void
    private let _forEach: (@escaping (Element) throws -> Void) -> AnyPublisher<Void, Error>
    
    public init<P: Paginator>(_ paginator: P) where P.Element == Element {
        _get = paginator.get
        _count = { paginator.count }
        _prefetch = paginator.prefetch
        _getCriteria = { paginator.criteria }
        _setCriteria = { paginator.criteria = $0 }
        _reload = paginator.reload
        _forEach = paginator.forEach
    }
    
    public func get(index: Int) -> AnyPublisher<Element, Error> {
        return _get(index)
    }
    
    public var count: CurrentValueSubject<Int?, Never> {
        _count()
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
    
    public func forEach(_ body: @escaping (Element) throws -> Void) -> AnyPublisher<Void, Error> {
        return _forEach(body)
    }
}

@available(iOS 13.0.0, *)
extension Paginator {
    public func eraseToAnyPaginator() -> AnyPaginator<Element> {
        return AnyPaginator(self)
    }
}
