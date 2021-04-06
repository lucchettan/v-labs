import SwiftUI

/// A helper view that reads an environment object from the environment. Useful in cases where you cannot directly use `@EnvironmentObject`, like in a `ButtonStyle` or `OWOWTextFieldStyle`.
@available(iOS 13.0.0, *)
public struct EnvironmentObjectReader<Content: View, Object: ObservableObject>: View {

    // MARK: State
    
    @EnvironmentObject private var object: Object
    
    private var content: (Object) -> Content
    
    // MARK: Init
    
    public init(@ViewBuilder content: @escaping (Object) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(object)
    }
    
}
