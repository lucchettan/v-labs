import Combine

@available(iOS 13.0.0, *)
extension Publisher where Failure == Never {
    /// The same as `assign`, but without creating a strong reference on `object`.
    public func weakAssign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root) -> AnyCancellable {
        let proxy = WeakProxy(object)
        
        return self.map { $0 }
            .assign(to: \WeakProxy[keyPath], on: proxy)
    }
    
    /// The same as `assign`, but without creating a strong reference on `object`.
    public func weakAssign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output?>, on object: Root) -> AnyCancellable {
        let proxy = WeakProxy(object)
        
        return self.map { $0 }
            .assign(to: \WeakProxy[keyPath], on: proxy)
    }
}
