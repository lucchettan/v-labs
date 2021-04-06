import SwiftUI

@available(iOS 13, *)
extension View {
    /// Converts the receiver to an instance of `AnyView`.
    @inlinable
    public func erasedToAnyView() -> AnyView {
        return AnyView(self)
    }
}

@available(iOS 13, *)
extension AnyView {
    /// Converts the receiver to an instance of `AnyView`.
    @inlinable
    @available(*, deprecated, message: "Unnecessary erasion – view is already `AnyView`")
    public func erasedToAnyView() -> AnyView {
        return self
    }
}
