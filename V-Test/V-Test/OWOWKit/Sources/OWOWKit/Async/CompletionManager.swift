import Foundation

/// A manager for callback closures, supporting both closures that are
/// meant to be called once and closures that can be called multiple
/// times.
public class CompletionManager<Element> {
    
    /// A closure that can be called to deregister a completion closure.
    public typealias CancelClosure = () -> Void
    
    /// A private wrapper classs that allows the closures to be identified in a Set.
    private class Handler: Hashable {
        
        /// The wrapped handler.
        var handler: (Element) -> Void
        
        /// Initialises a new wrapped handler.
        init(_ handler: @escaping (Element) -> Void) {
            self.handler = handler
        }
        
        /// `Hashable` conformance.
        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(self))
        }
        
        /// `Equatable` conformance. `Handler` provides the notion of identity to its closure by using its own object instance identity.
        static func == (lhs: CompletionManager<Element>.Handler, rhs: CompletionManager<Element>.Handler) -> Bool {
            return lhs === rhs
        }
        
    }
    
    /// The currently registered handlers.
    private var handlers = Set<Handler>()
    
    /// A cached result. After a result is published, it is cached here for new subscribers.
    private var cachedResult: Element?
    
    /// When set to true, the `Handlers` Set will be emptied after each publish event.
    private let oneTime: Bool
    
    /// Initialises a new completion manager.
    ///
    /// - parameter oneTime: When `true`, all registered handlers will be unsubscribed after receiving exactly one event.
    public init(oneTime: Bool = true) {
        self.oneTime = oneTime
    }
    
    /// Registers the given `handler`.
    ///
    /// - returns: A cancel closure, that can be called to unregister the handler before completion.
    public func add(handler: @escaping (Element) -> Void) -> CancelClosure {
        if let result = cachedResult {
            handler(result)
            
            if oneTime {
                return {}
            }
        }
        
        let wrapped = Handler(handler)
        handlers.insert(wrapped)
        
        return { [weak self] in
            // We don't want to keep a reference to the `CompletionHandler` through this closure. If the `CompletionHandler` is not referenced anymore, there is no way to publish an element to it, so it may be deallocated.
            guard let `self` = self else { return }
            
            self.handlers.remove(wrapped)
        }
    }
    
    /// Publishes the given `element` to all subscribers.
    public func publish(element: Element) {
        cachedResult = element
        
        for handler in handlers {
            handler.handler(element)
        }
        
        if oneTime {
            handlers.removeAll()
        }
    }
}
