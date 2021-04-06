//
//  MappedPaginator.swift
//  OWOWKit
//
//  Created by Robbert Brandsma on 19/08/2019.
//

import Combine

@available(iOS 13.0.0, *)
public class MappedPaginator<Upstream: Paginator, Output>: Paginator {
    private let upstream: Upstream
    private let transform: (Upstream.Element) throws -> Element
    
    public init(_ paginator: Upstream, transform: @escaping (Upstream.Element) throws -> Element) {
        upstream = paginator
        self.transform = transform
    }
    
    public func get(index: Int) -> AnyPublisher<Output, Error> {
        upstream.get(index: index)
            .tryMap(transform)
            .eraseToAnyPublisher()
    }
    
    public var count: CurrentValueSubject<Int?, Never> {
        upstream.count
    }
    
    public func prefetch(indices: [Int]) {
        upstream.prefetch(indices: indices)
    }
    
    public var criteria: CriteriaSet {
        get {
            upstream.criteria
        }
        set {
            upstream.criteria = newValue
        }
    }
    
    public func reload() {
        upstream.reload()
    }
    
    public func forEach(_ body: @escaping (Output) throws -> Void) -> AnyPublisher<Void, Error> {
        upstream.forEach { try body(self.transform($0)) }
    }
}

@available(iOS 13.0.0, *)
extension Paginator {
    public func map<Output>(_ transform: @escaping (Element) -> Output) -> MappedPaginator<Self, Output> {
        return MappedPaginator(self, transform: transform)
    }
}
