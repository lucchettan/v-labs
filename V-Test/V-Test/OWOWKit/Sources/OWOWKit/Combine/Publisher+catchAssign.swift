import Combine

@available(iOS 13.0.0, *)
extension Publishers {
    public struct CatchAssign<Upstream, Object>: Publisher where Upstream : Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Never
        
        /// The publisher from which this publisher receives elements.
        let upstream: Upstream
        
        /// The object to which this publisher assigns errors.
        let object: Object
        
        // In order to support optionals, we use a closure here.
        /// The closure that writes to `object`.
        let assign: (Object, Upstream.Failure) -> ()

        public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Output {
            upstream.catch { error -> Empty<Output, Never> in
                self.assign(self.object, error)
                
                return Empty()
            }.receive(subscriber: subscriber)
        }
    }
}

@available(iOS 13.0.0, *)
extension Publisher {
    /// Catches errors and assigns them to `keyPath` on `object`. The resulting publisher will complete if an upstream publisher produces an error.
    public func catchAssign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Failure>, on object: Root) -> Publishers.CatchAssign<Self, Root> {
        return Publishers.CatchAssign(
            upstream: self,
            object: object,
            assign: { object, error in object[keyPath: keyPath] = error }
        )
    }
    
    /// Catches errors and assigns them to `keyPath` on `object`. The resulting publisher will complete if an upstream publisher produces an error.
    public func catchAssign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Failure?>, on object: Root) -> Publishers.CatchAssign<Self, Root> {
        return Publishers.CatchAssign(
            upstream: self,
            object: object,
            assign: { object, error in object[keyPath: keyPath] = error }
        )
    }
    
    /// Catches errors and assigns them to `keyPath` on `object`. The resulting publisher will complete if an upstream publisher produces an error.
    public func weakCatchAssign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Self.Failure>, on object: Root) -> Publishers.CatchAssign<Self, WeakProxy<Root>> {
        return Publishers.CatchAssign(
            upstream: self,
            object: WeakProxy(object),
            assign: { object, error in object[keyPath] = error }
        )
    }
    
    /// Catches errors and assigns them to `keyPath` on `object`. The resulting publisher will complete if an upstream publisher produces an error.
    public func weakCatchAssign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Failure?>, on object: Root) -> Publishers.CatchAssign<Self, WeakProxy<Root>> {
        return Publishers.CatchAssign(
            upstream: self,
            object: WeakProxy(object),
            assign: { object, error in object[keyPath] = error }
        )
    }
}
