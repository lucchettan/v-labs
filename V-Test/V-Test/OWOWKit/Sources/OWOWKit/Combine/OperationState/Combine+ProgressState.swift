import Combine

/// A publisher that transforms an `Upstream` publisher to elements of `ProgressState`.
@available(iOS 13, tvOS 13, *)
public struct ProgressStatePublisher<Upstream>: Publisher where Upstream: Publisher {
    public typealias Output = ProgressState
    public typealias Failure = Never
    
    fileprivate var upstream: Upstream
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        upstream
            .convertToOperationState()
            .map(\.progress)
            .receive(subscriber: subscriber)
    }
}

@available(iOS 13, tvOS 13, *)
public extension Publisher {
    /// Converts elements of the publisher to `ProgressState`.
    func convertToProgressState() -> ProgressStatePublisher<Self> {
        ProgressStatePublisher(upstream: self)
    }
}
