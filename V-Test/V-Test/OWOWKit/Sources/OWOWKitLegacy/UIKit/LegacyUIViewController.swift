import UIKit
import OWOWKit

extension UIViewController {
    /// Registers a `whenFailure` handler on `future` that calls `presentError`.
    /// - Parameter future: The future to register the handler on.
    /// - Parameter title: The title of the error dialog.
    /// - Parameter dismissButtonTitle: The dimiss button title of the error dialog.
    public func showErrors<T>(
        of future: Future<T>,
        title: String = "Something went wrong",
        dismissButtonTitle: String = "Dismiss"
    ) {
        future
            .receive(on: .main)
            .whenFailure { [weak self] error in
                self?.presentError(
                    error,
                    title: title,
                    dismissButtonTitle: dismissButtonTitle
                )
            }
    }
}
