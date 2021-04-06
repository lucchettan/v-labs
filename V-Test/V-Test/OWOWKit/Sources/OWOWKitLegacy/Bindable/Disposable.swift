//
//  Disposable.swift
//  OWOWKit
//
//  Created by Robbert Brandsma on 19/08/2019.
//

public protocol Disposable {
    func dispose()
}

extension Disposable {
    public func add(to disposeBag: DisposeBag) {
        disposeBag.add(self)
    }
}

extension Array: Disposable where Element == Disposable {
    public func dispose() {
        for disposable in self {
            disposable.dispose()
        }
    }
}

public final class DisposeBag: Disposable {
    private var disposables = [Disposable]()
    
    public init() {}
    
    public func add(_ disposables: Disposable...) {
        self.disposables.append(disposables)
    }
    
    public func dispose() {
        for disposable in disposables {
            disposable.dispose()
        }
    }
    
    deinit {
        self.dispose()
    }
}

public struct ClosureDisposable: Disposable {
    private var _dispose: () -> Void
    
    public init(_ dispose: @escaping () -> Void) {
        self._dispose = dispose
    }
    
    public func dispose() {
        self._dispose()
    }
}
