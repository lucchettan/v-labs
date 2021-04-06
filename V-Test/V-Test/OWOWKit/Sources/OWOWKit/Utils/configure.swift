//
//  configure.swift
//  OWOWKit
//
//  Created by Robbert Brandsma on 22/08/2019.
//

/// This is a helper that is mainly useful for configuring objects with complex generics, such as custom UIView subclasses.
/// When using a closure to configure the instance, the compiler cannot infer the type, requiring you to write out the entire
/// type at the variable declaration. By using this helper, the compiler can infer the type.
///
/// Example usage:
///
/// `let view = configure(UIView()) { $0.backgroundColor = .red }`
public func configure<T: AnyObject>(_ target: T, configure: (T) -> Void) -> T {
    configure(target)
    return target
}
