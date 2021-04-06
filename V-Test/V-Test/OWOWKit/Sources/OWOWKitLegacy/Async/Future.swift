import Foundation

/// A lightweight `Promise` class. When returning an asynchronous result from a method, you create a `Promise` to get a future.
/// When the result is available, call `fulfill` on the promise, which in turn causes all handlers registered on the `Future`
public class Promise<Value> {
    
    /// Create a new `Promise`.
    public init() {}
    
    /// The `Future` of this `Promise`.
    public let futureResult = Future<Value>()
    
    /// Fulfills the promise with the given `result`.
    public func fulfill(_ result: Swift.Result<Value, Error>) {
        futureResult.completionManager.publish(element: result)
    }
    
    /// Fulfill the promise with the given `result`.
    /// This causes all closures registered on the `Future` to resolve.
    public func succeed(_ result: Value) {
        fulfill(.success(result))
    }
    
    /// Cause the promise to fail with the given `error`.
    public func fail(_ error: Error) {
        fulfill(.failure(error))
    }
    
}

/// A lightweight `Future` value that represents a value that will be available in the future.
/// In order to get a `Future<T>`, you need to make a `Promise<T>` first.
///
/// Note that, even though `Future` is a `struct`, it has reference semantics.
public struct Future<Value> {
    
    /// The type that this future resolves to.
    public typealias Result = Swift.Result<Value, Error>
    
    /// The completion manager that underlies the future. The `Promise` will publish its result on this completion manager.
    fileprivate var completionManager = CompletionManager<Result>()
    
    /// The initialiser is `fileprivate` because a `Future` may only be created by a `Promise`.
    fileprivate init() {}
    
    /// Registers a closure to execute when the future completes. If the result
    /// of the closure is already available, it might be called synchronously
    /// on the calling thread.
    ///
    /// - parameter handler: The handler closure to register.
    /// - returns: A cancel closure that can be used to unregister the `handler`.
    public func whenCompleteCancellable(_ handler: @escaping (Result) -> Void) -> (() -> Void) {
        return completionManager.add(handler: handler)
    }
    
    public func whenComplete(_ handler: @escaping (Result) -> Void) {
        _ = whenCompleteCancellable(handler)
    }
    
    public func whenSuccess(_ handler: @escaping (Value) -> Void) {
        whenComplete { result in
            if case .success(let value) = result {
                handler(value)
            }
        }
    }
    
    public func whenFailure(_ handler: @escaping (Error) -> Void) {
        whenComplete { result in
            if case .failure(let error) = result {
                handler(error)
            }
        }
    }
    
    /// Writes the result of the future into the given `promise`.
    public func complete(into promise: Promise<Value>) {
        _ = self.whenCompleteCancellable { result in
            promise.fulfill(result)
        }
    }
    
    /// Maps the future synchronously to a value of type `NewValue`.
    public func map<NewValue>(_ callback: @escaping (Value) throws -> NewValue) -> Future<NewValue> {
        let promise = Promise<NewValue>()
        
        _ = self.whenCompleteCancellable { result in
            do {
                switch result {
                case .success(let value):
                    let newResult = try callback(value)
                    promise.succeed(newResult)
                case .failure(let error):
                    promise.fail(error)
                }
            } catch {
                promise.fail(error)
            }
        }
        
        return promise.futureResult
    }
    
    public func flatMap<NewValue>(_ callback: @escaping (Value) throws -> Future<NewValue>) -> Future<NewValue> {
        let promise = Promise<NewValue>()
        
        _ = self.whenCompleteCancellable { result in
            do {
                switch result {
                case .success(let value):
                    let newFuture = try callback(value)
                    newFuture.complete(into: promise)
                case .failure(let error):
                    promise.fail(error)
                }
            } catch {
                promise.fail(error)
            }
        }
        
        return promise.futureResult
    }
    
    /// Useful with, for example, `Future<ResponseBody<VoidResponse>>`.
    /// This maps values to `Void`, but leaves errors unchanged.
    public func ignoreResults() -> Future<Void> {
        return self.map { _ in }
    }
    
    /// Receive results on the given `queue`.
    public func receive(on queue: DispatchQueue) -> Future<Value> {
        let promise = Promise<Value>()
        
        self.whenComplete { result in
            queue.async {
                promise.fulfill(result)
            }
        }
        
        return promise.futureResult
    }
    
    /// Initializes a completed future with the given `result`.
    public init(result: Result) {
        completionManager.publish(element: result)
    }
    
    /// Initializes a completed future with the given `value`.
    public init(_ value: Value) {
        self.init(result: .success(value))
    }
    
    /// Initializes a completed future with the given `error`.
    public init(error: Error) {
        self.init(result: .failure(error))
    }
    
}
