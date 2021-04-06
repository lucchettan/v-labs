import SwiftUI

/// A view that initializes it's content lazily.
///
/// It is useful to create a `NavigationLink` that only initializes it's destination after it is tapped:
///
/// ```
/// NavigationLink(destination: Lazy(MyView())) { /* label */ }
/// ```
///
/// This way, `MyView()` will only be evaluated after the `NavigationLink` is tapped.
///
@available(iOS 13.0.0, *)
public struct Lazy<Content: View>: View {
    /// The content.
    private let content: () -> Content
    
    /// - parameter content: The content to render lazily.
    public init(_ content: @autoclosure @escaping () -> Content) {
        self.content = content
    }
    
    /// - parameter content: The content to render lazily.
    public init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
    }
}
