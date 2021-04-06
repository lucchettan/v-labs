//
//  _Bindable.swift
//  OWOWKit
//
//  Created by Robbert Brandsma on 19/08/2019.
//

/// A protocol that defines core operations for `Bindable` and related types.
public protocol _Bindable {
    associatedtype Subject
    
    /// Add an observation for the given `object`. The observation is weakly referenced so it will stop when `object` is deallocated, or when the returned `Disposable` is disposed.
    ///
    /// - parameter object: The object that the observation is added for. The object is weakly referenced and the observation is removed when the object is deallocated.
    /// - parameter handler: The handler that is executed when the observed value changes. The given `object` is passed as the first parameter, and the changed value as the second parameter.
    /// - returns: A `Disposable` that can be used to unregister the observation before `object` is deallocated.
    @discardableResult
    func observe<O: AnyObject>(for object: O, handler: @escaping (O, Subject) -> Void) -> Disposable
}
