import SwiftUI

@available(iOS 13, *)
extension View {
    /// The same as calling `ignoresSafeArea(.keyboard, edges: .all)`, but also available on iOS 13, where it does nothing.
    /// Do not use in apps targetting only iOS 14 and above.
    @available(iOS, introduced: 13, deprecated: 14, message: "Use ignoresSafeArea(.keyboard, edges: .all) when it is available")
    @ViewBuilder
    public func ignoresKeyboardSafeArea() -> some View {
        if #available(iOS 14, *) {
            self.ignoresSafeArea(.keyboard, edges: .all)
        } else {
            self
        }
    }
}
