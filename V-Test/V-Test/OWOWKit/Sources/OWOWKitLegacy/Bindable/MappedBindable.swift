//
//  MappedBindable.swift
//  OWOWKit
//
//  Created by Robbert Brandsma on 19/08/2019.
//

/// A `Bindable` that has been mapped from `Base.Subject` to `Output`.
/// You don't create mapped bindables yourself. Instead, you create them by calling `map` on a `Bindable`.
@dynamicMemberLookup
public struct MappedBindable<Base: _Bindable, Output>: _Bindable {
    public typealias Subject = Output
    
    private let transform: (Base.Subject) -> (Output)
    private let base: Base
    
    internal init(base: Base, transform: @escaping (Base.Subject) -> (Output)) {
        self.base = base
        self.transform = transform
    }
    
    @discardableResult
    public func observe<O: AnyObject>(for object: O, handler: @escaping (O, Output) -> Void) -> Disposable {
        return base.observe(for: object) { (object: O, observed: Base.Subject) in
            let transformed = self.transform(observed)
            handler(object, transformed)
        }
    }
}
