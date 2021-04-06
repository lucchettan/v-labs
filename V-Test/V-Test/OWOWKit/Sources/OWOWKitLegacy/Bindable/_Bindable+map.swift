//
//  _Bindable+Map.swift
//  OWOWKit
//
//  Created by Robbert Brandsma on 19/08/2019.
//

extension _Bindable {
    /// Maps the value to `Output` using the given `transform`.
    ///
    /// - parameter transform: A function that transforms the `Subject` to `Output`.
    /// - returns: The mapped bindable.
    public func map<Output>(
        transform: @escaping (Subject) -> Output
    ) -> MappedBindable<Self, Output> {
        return MappedBindable(base: self) { observed in
            return transform(observed)
        }
    }
    
    /// Maps the value of `sourceKeyPath` to `Output` using the given `transform`.
    ///
    /// - parameter sourceKeyPath: The key path that is observed.
    /// - parameter transform: A function that transforms the `Input` to `Output`.
    /// - returns: The mapped bindable.
    public func map<Input, Output>(
        _ sourceKeyPath: KeyPath<Subject, Input>,
        _ transform: @escaping (Input) -> (Output)
    ) -> MappedBindable<Self, Output> {
        return MappedBindable(base: self) { observed in
            return transform(
                observed[keyPath: sourceKeyPath]
            )
        }
    }
    
    /// Maps the value of `sourceKeyPath1` and `sourceKeyPath2` to `Output` using the given `transform`.
    ///
    /// - parameter sourceKeyPath1: The first key path that is observed.
    /// - parameter sourceKeyPath2: The second key path that is observed.
    /// - parameter transform: A function that transforms the `Input1` and `Input2` to `Output`.
    /// - returns: The mapped bindable.
    public func map<Input1, Input2, Output>(
        _ sourceKeyPath1: KeyPath<Subject, Input1>,
        _ sourceKeyPath2: KeyPath<Subject, Input2>,
        _ transform: @escaping (Input1, Input2) -> Output
    ) -> MappedBindable<Self, Output> {
        return MappedBindable(base: self) { observed in
            return transform(
                observed[keyPath: sourceKeyPath1],
                observed[keyPath: sourceKeyPath2]
            )
        }
    }
    
    /// Maps the value of `sourceKeyPath1`, `sourceKeyPath2` and `sourceKeyPath3` to `Output` using the given `transform`.
    ///
    /// - parameter sourceKeyPath1: The first key path that is observed.
    /// - parameter sourceKeyPath2: The second key path that is observed.
    /// - parameter sourceKeyPath3: The third key path that is observed.
    /// - parameter transform: A function that transforms the `Input1`, `Input2` and `Input3` to `Output`.
    /// - returns: The mapped bindable.
    public func map<Input1, Input2, Input3, Output>(
        _ sourceKeyPath1: KeyPath<Subject, Input1>,
        _ sourceKeyPath2: KeyPath<Subject, Input2>,
        _ sourceKeyPath3: KeyPath<Subject, Input3>,
        _ transform: @escaping (Input1, Input2, Input3) -> Output
    ) -> MappedBindable<Self, Output> {
        return MappedBindable(base: self) { observed in
            return transform(
                observed[keyPath: sourceKeyPath1],
                observed[keyPath: sourceKeyPath2],
                observed[keyPath: sourceKeyPath3]
            )
        }
    }
    
    /// Maps the value of `sourceKeyPath1`, `sourceKeyPath2`, `sourceKeyPath3` and `sourceKeyPath4` to `Output` using the given `transform`.
    ///
    /// - parameter sourceKeyPath1: The first key path that is observed.
    /// - parameter sourceKeyPath2: The second key path that is observed.
    /// - parameter sourceKeyPath3: The third key path that is observed.
    /// - parameter sourceKeyPath4: The fourth key path that is observed.
    /// - parameter transform: A function that transforms the `Input1`, `Input2`, `Input3` and `Input4` to `Output`.
    /// - returns: The mapped bindable.
    public func map<Input1, Input2, Input3, Input4, Output>(
        _ sourceKeyPath1: KeyPath<Subject, Input1>,
        _ sourceKeyPath2: KeyPath<Subject, Input2>,
        _ sourceKeyPath3: KeyPath<Subject, Input3>,
        _ sourceKeyPath4: KeyPath<Subject, Input4>,
        _ transform: @escaping (Input1, Input2, Input3, Input4) -> Output
    ) -> MappedBindable<Self, Output> {
        return MappedBindable(base: self) { observed in
            return transform(
                observed[keyPath: sourceKeyPath1],
                observed[keyPath: sourceKeyPath2],
                observed[keyPath: sourceKeyPath3],
                observed[keyPath: sourceKeyPath4]
            )
        }
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Subject, T>) -> MappedBindable<Self, T> {
        return self.map { $0[keyPath: keyPath] }
    }
}
