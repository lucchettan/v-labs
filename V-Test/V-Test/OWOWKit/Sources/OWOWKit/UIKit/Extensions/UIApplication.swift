import UIKit

extension UIApplication {
    /// Sends the `resignFirstResponder` action.
    public func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
