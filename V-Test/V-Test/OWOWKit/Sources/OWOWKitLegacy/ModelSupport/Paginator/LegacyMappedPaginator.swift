//
//  MappedPaginator.swift
//  OWOWKit
//
//  Created by Robbert Brandsma on 19/08/2019.
//

import OWOWKit

public class MappedPaginator<Element>: Paginator {
    private let _getIndex: (Int) -> Future<Element>
    private let _getPage: (Int) -> Future<[Element]>
    private let _onCount: (@escaping (Int?) -> Void) -> (() -> Void)
    private let _prefetch: ([Int]) -> Void
    private let _getCriteria: () -> CriteriaSet
    private let _setCriteria: (CriteriaSet) -> Void
    private let _reload: () -> Void
    
    public init<P: Paginator>(_ paginator: P, transform: @escaping (P.Element) -> Element) {
        _getIndex = { index in
            let original = paginator.get(index: index)
            return original.map(transform)
        }
        _getPage = { page in
            let original = paginator.get(page: page)
            return original.map { $0.map(transform) }
        }
        _onCount = paginator.onCount
        _prefetch = paginator.prefetch
        _getCriteria = { paginator.criteria }
        _setCriteria = { paginator.criteria = $0 }
        _reload = paginator.reload
    }
    
    public func get(index: Int) -> Future<Element> {
        return _getIndex(index)
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
    public func map<Output>(_ transform: @escaping (Element) -> Output) -> MappedPaginator<Output> {
        return MappedPaginator(self, transform: transform)
    }
    
    public func asBindable() -> MappedPaginator<Bindable<Element>> {
        return map(Bindable.init(wrappedValue:))
    }
}
