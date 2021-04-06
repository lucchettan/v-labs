import Combine
import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13, watchOS 6, *)
public struct ObjectDidChangePublisher<ObjectWillChangePublisher: Publisher>: Publisher {
    private let upstream: ObjectWillChangePublisher
    public typealias Output = ObjectWillChangePublisher.Output
    public typealias Failure = ObjectWillChangePublisher.Failure
    
    fileprivate init(upstream: ObjectWillChangePublisher) {
        self.upstream = upstream
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        self.upstream
            .receive(on: DispatchQueue.main) /// This essentially just delays the publisher until after the `willSet` property observer. Published property changes must happen on the main thread anyway.
            .receive(subscriber: subscriber)
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13, watchOS 6, *)
extension ObservableObject {
    public var objectDidChange: ObjectDidChangePublisher<ObjectWillChangePublisher> {
        ObjectDidChangePublisher(upstream: objectWillChange)
    }
}
