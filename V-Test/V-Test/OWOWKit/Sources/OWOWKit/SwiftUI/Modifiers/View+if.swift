import SwiftUI

@available(iOS 13.0.0, *)
extension View {
    /// Applies a view modifier conditionally.
    /// - Parameters:
    ///   - condition: The condition that has to be `true` for the `closure` to be appled.
    ///   - closure: The closure to apply if `condition` is `true`.
    /// - Returns: The result of calling the closure with the receiver if `condition` is `true`. Otherwise, the receiver.
    @inlinable
    public func `if`<T: View>(_ condition: Bool, closure: (Self) -> T) -> some View {
        if condition {
            return closure(self)
                .erasedToAnyView()
        } else {
            return self
                .erasedToAnyView()
        }
    }
}
