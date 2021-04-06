import SwiftUI

/// A `Button` that dismisses the presentation mode.
@available(iOS 13, tvOS 13, *)
public struct BackButton<Label: View>: View {
    /// The presentation mode binding.
    @Environment(\.presentationMode) var presentationMode
    
    /// Content to show as the label.
    let label: Label
    
    /// 🌷
    /// - Parameter label: A view that describes the purpose of the button.
    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }
    
    public var body: some View {
        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
            label
        }
    }
}
