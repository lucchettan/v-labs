import SwiftUI

fileprivate struct TabIndexKey: EnvironmentKey {
    static var defaultValue: Int? {
        return nil
    }
}

@available(iOS 13.0.0, *)
extension EnvironmentValues {
    /// The tab index for the view. It works like [the HTML property](https://developer.mozilla.org/en-US/docs/Web/API/HTMLOrForeignElement/tabIndex),
    /// but a notable difference is that, unlike in HTML, values need to be sequential in order to be able to "tab" from one field to the next.
    public var tabIndex: Int? {
        get {
            return self[TabIndexKey.self]
        }
        set {
            self[TabIndexKey.self] = newValue
        }
    }
}

@available(iOS 13.0.0, *)
extension View {
    /// Sets the tab index for the view. It works like [the HTML property](https://developer.mozilla.org/en-US/docs/Web/API/HTMLOrForeignElement/tabIndex),
    /// but a notable difference is that, unlike in HTML, values need to be sequential in order to be able to "tab" from one field to the next.
    ///
    /// This modifier works in conjunction with `OWOWTextField.`
    @inlinable
    public func tabIndex(_ tabIndex: Int?) -> some View {
        return self.environment(\.tabIndex, tabIndex)
    }
}
