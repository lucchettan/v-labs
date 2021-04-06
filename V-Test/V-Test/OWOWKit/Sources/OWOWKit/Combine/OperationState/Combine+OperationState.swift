import Combine

/// A publisher that transforms an `Upstream` publisher to elements of `OperationState`.
@available(iOS 13, tvOS 13, *)
public struct OperationStatePublisher<Upstream>: Publisher where Upstream: Publisher {
    public typealias Output = OperationState<Upstream.Output, Upstream.Failure>
    public typealias Failure = Never
    
    fileprivate var upstream: Upstream
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        upstream
            .map { Output.finished($0) }
            .prepend(Output.inProgress)
            .catch { Just(Output.error($0)) }
            .receive(subscriber: subscriber)
    }
}

@available(iOS 13, tvOS 13, *)
public extension Publisher {
    /// Converts elements of the publisher to `OperationState`.
    func convertToOperationState() -> OperationStatePublisher<Self> {
        OperationStatePublisher(upstream: self)
    }
}
