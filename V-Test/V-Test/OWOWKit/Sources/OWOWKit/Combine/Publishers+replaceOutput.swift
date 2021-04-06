import Combine

@available(iOS 13.0.0, *)
extension Publisher {
    /// Returns a new publisher that replaces output events of the receiver with `replacement`.
    public func replaceOutput<T>(with replacement: T) -> Publishers.Map<Self, T> {
        return self.map { _ in replacement }
    }
}
