//
//  _Bindable+observeUnique.swift
//  OWOWKit
//
//  Created by Robbert Brandsma on 19/08/2019.
//

extension Bindable {
    /// Add an observation for the given `sourceKeyPath` that is only executed when it's value changes.
    ///
    /// - parameter sourceKeyPath: The key path that is observed.
    /// - parameter object: The object that the observation is added for. The object is weakly referenced and the observation is removed when the object is deallocated.
    /// - parameter handler: The handler that is executed when the observed value changes. The given `object` is passed as the first parameter, and the changed value as the second parameter.
    /// - returns: A `Disposable` that can be used to unregister the observation before `object` is deallocated.
    @discardableResult
    public func observeUnique<O: AnyObject, T: Equatable>(_ sourceKeyPath: KeyPath<Value, T>, for object: O, handler: @escaping (O, T) -> Void) -> Disposable {
        var lastValue: T?
        return observe(for: object) { object, observed in
            let currentValue = observed[keyPath: sourceKeyPath]
            defer { lastValue = currentValue }
            
            if lastValue != currentValue {
                handler(object, currentValue)
            }
        }
    }
}
