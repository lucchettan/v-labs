//
//  _Bindable+bind.swift
//  OWOWKit
//
//  Created by Robbert Brandsma on 19/08/2019.
//

extension _Bindable {
    /// Binds the value to `object` on `targetKeyPath`.
    ///
    /// - parameter object: The object that the observation is added for. The object is weakly referenced and the observation is removed when the object is deallocated.
    /// - parameter targetKeyPath: The key path on `object` that values will be written to.
    /// - returns: A `Disposable` that can be used to unregister the observation before `object` is deallocated.
    @discardableResult
    public func bind<O: AnyObject>(to object: O, _ targetKeyPath: ReferenceWritableKeyPath<O, Subject>) -> Disposable {
        return observe(for: object) { object, observed in
            object[keyPath: targetKeyPath] = observed
        }
    }
    
    /// Binds the value to `object` on `targetKeyPath`.
    ///
    /// - parameter object: The object that the observation is added for. The object is weakly referenced and the observation is removed when the object is deallocated.
    /// - parameter targetKeyPath: The key path on `object` that values will be written to.
    /// - returns: A `Disposable` that can be used to unregister the observation before `object` is deallocated.
    @discardableResult
    public func bind<O: AnyObject>(to object: O, _ targetKeyPath: ReferenceWritableKeyPath<O, Subject?>) -> Disposable {
        return observe(for: object) { object, observed in
            object[keyPath: targetKeyPath] = observed as Subject?
        }
    }
    
    /// Binds the value of `sourceKeyPath` to `object` on `targetKeyPath`.
    ///
    /// - parameter sourceKeyPath: The key path that is observed.
    /// - parameter object: The object that the observation is added for. The object is weakly referenced and the observation is removed when the object is deallocated.
    /// - parameter targetKeyPath: The key path on `object` that values will be written to.
    /// - returns: A `Disposable` that can be used to unregister the observation before `object` is deallocated.
    @discardableResult
    public func bind<O: AnyObject, T>(_ sourceKeyPath: KeyPath<Subject, T>, to object: O, _ targetKeyPath: ReferenceWritableKeyPath<O, T>) -> Disposable {
        return observe(for: object) { object, observed in
            let value = observed[keyPath: sourceKeyPath]
            object[keyPath: targetKeyPath] = value
        }
    }
}
