//
//  Bindable.swift
//  OWOWKit
//
//  Created by Robbert Brandsma on 18/08/2019.
//

import Foundation

/// An instance that wraps a value of `Element`, to bind it to the UI.
/// Because this is meant to bind a value to UI, all observers will be executed on the main thread.
///
/// ## Example usage
///
/// Given a simple `User` struct with a property `username`, one could make it bindable using the `Bindable` init.
/// Then, the username could be bound to the `text` property on a `UILabel`, which will be automatically updated when the `username` changes.
///
/// ```
/// let bindable = Bindable<User>(user)
/// let label = UILabel()
/// bindable.bind(\.username, to: label, \.text)
/// ```
@propertyWrapper @dynamicMemberLookup
public class Bindable<Value>: _Bindable {
    public typealias Subject = Value
    
    /// - warning: Do not read this value for display in the UI. Use `observe` or a binding instead.
    public var wrappedValue: Value {
        didSet {
            guard !observationsScheduled else { return }
            observationsScheduled = true
            
            DispatchQueue.main.async {
                self.observationsScheduled = false
                self.observations = self.observations.filter { $0.value(self.wrappedValue) }
            }
        }
    }
    
    public var projectedValue: Bindable<Value> {
        self
    }
    
    /// The `id` of the last observation. This is an implementation detail.
    private var lastObservationId = 0
    
    /// The `id` of the next observation. Getting this will cause `lastObservationId` to increase.
    private var nextObservationId: Int {
        lastObservationId += 1
        return lastObservationId
    }
    
    /// Used to make sure that a sequence of changes will not cause the observations to run for every small change.
    private var observationsScheduled = false
    
    /// An array of observation closures.
    /// The return value of an observation is wether or not we should keep it.
    private var observations = [Int: (Value) -> Bool]()
    
    /// Initialise a new `Bindable` with the given value.
    public init(_ value: Value) {
        self.wrappedValue = value
    }
    
    /// Initialise a new `Bindable` with the given value.
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    /// Add an observation for the given `object`. The observation is weakly referenced so it will stop when `object` is deallocated, or when the returned `Disposable` is disposed.
    ///
    /// - parameter object: The object that the observation is added for. The object is weakly referenced and the observation is removed when the object is deallocated.
    /// - parameter handler: The handler that is executed when the observed value changes. The given `object` is passed as the first parameter, and the changed value as the second parameter.
    /// - returns: A `Disposable` that can be used to unregister the observation before `object` is deallocated.
    @discardableResult
    public func observe<O: AnyObject>(for object: O, handler: @escaping (O, Value) -> Void) -> Disposable {
        let id = nextObservationId
        observations[id] = { [weak object] value in
            guard let object = object else {
                return false
            }
            
            handler(object, value)
            return true
        }
        handler(object, wrappedValue)
        
        return ClosureDisposable { [weak self] in
            guard let self = self else { return }
            self.observations[id] = nil
        }
    }
}
