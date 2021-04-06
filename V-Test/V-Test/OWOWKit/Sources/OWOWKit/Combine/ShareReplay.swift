import Combine
import Foundation

@available(iOS 13, *)
extension Publisher {
    /// Ensure that all subscribers see the same sequence of emitted items, even if they subscribe afther the publisher has begun emitting items.
    ///
    /// - Parameter buffer: The amount of items that can be replayed.
    public func shareReplay(_ buffer: Int) -> Publishers.ShareReplay<Self> {
        Publishers.ShareReplay(upstream: self, buffer: buffer)
    }
}

@available(iOS 13, *)
extension Publishers {
    public struct ShareReplay<Upstream: Publisher>: Publisher {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure
        
        private typealias InternalPublisher = Publishers.Autoconnect<Publishers.Multicast<Upstream, ReplaySubject<Upstream.Output, Upstream.Failure>>>
        private let publisher: InternalPublisher
        
        init(upstream: Upstream, buffer: Int) {
            self.publisher = upstream.multicast(subject: ReplaySubject(buffer))
                .autoconnect()
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            publisher.receive(subscriber: subscriber)
        }
    }
}

@available(iOS 13, *)
fileprivate final class ReplaySubject<Output, Failure: Error>: Subject {
    private let lock = NSRecursiveLock()
    
    private var buffer: [Output] = []
    private let bufferSize: Int
    
    private var subscriptions = [Subscriptions.ReplaySubject<Output, Failure>]()
    private var completion: Subscribers.Completion<Failure>?
    
    init(_ bufferSize: Int) {
        self.bufferSize = bufferSize
        buffer.reserveCapacity(bufferSize)
    }
    
    /// Establishes demand for a new upstream subscriptions
    func send(subscription: Subscription) {
        lock.lock()
        defer { lock.unlock() }
        
        subscription.request(.unlimited)
    }
    
    /// Sends a value to the subscriber.
    func send(_ value: Output) {
        lock.lock()
        defer { lock.unlock() }
        
        buffer.append(value)
        buffer = buffer.suffix(bufferSize)
        subscriptions.forEach { $0.receive(value) }
    }
    
    /// Sends a completion event to the subscriber.
    func send(completion: Subscribers.Completion<Failure>) {
        lock.lock()
        defer { lock.unlock() }
        
        self.completion = completion
        subscriptions.forEach { subscription in subscription.receive(completion: completion) }
    }
    
    func receive<Downstream: Subscriber>(subscriber: Downstream) where Downstream.Failure == Failure, Downstream.Input == Output {
        lock.lock()
        defer { lock.unlock() }
        
        let subscription = Subscriptions.ReplaySubject<Output, Failure>(downstream: AnySubscriber(subscriber))
        subscriber.receive(subscription: subscription)
        subscriptions.append(subscription)
        subscription.replay(buffer, completion: completion)
        }
}

@available(iOS 13, *)
fileprivate extension Subscriptions {
    final class ReplaySubject<Output, Failure: Error>: Subscription {
        private let downstream: AnySubscriber<Output, Failure>
        private var isCompleted = false
        private var demand: Subscribers.Demand = .none
        
        init(downstream: AnySubscriber<Output, Failure>) {
            self.downstream = downstream
        }
        
        func request(_ newDemand: Subscribers.Demand) {
            demand += newDemand
        }
        
        func cancel() {
            isCompleted = true
        }
        
        func receive(_ value: Output) {
            guard !isCompleted, demand > 0 else { return }
            
            demand += downstream.receive(value)
            demand -= 1
        }
        
        func receive(completion: Subscribers.Completion<Failure>) {
            guard !isCompleted else { return }
            isCompleted = true
            downstream.receive(completion: completion)
        }
        
        func replay(_ values: [Output], completion: Subscribers.Completion<Failure>?) {
            guard !isCompleted else { return }
            values.forEach { value in receive(value) }
            if let completion = completion { receive(completion: completion) }
        }
    }
}
