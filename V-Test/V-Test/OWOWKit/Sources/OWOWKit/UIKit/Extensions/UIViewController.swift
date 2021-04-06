#if canImport(UIKit)
import UIKit

extension UIViewController {
    
    /// Presents an alert for the given error.
    /// - Parameter error: The error to present an alert for.
    /// - Parameter title: The title of the error dialog.
    /// - Parameter dismissButtonTitle: The dismiss button title of the error dialog.
    public func presentError(
        _ error: Error,
        title: String = "Something went wrong",
        dismissButtonTitle: String = "Dismiss"
    ) {
        let alert = UIAlertController(
            title: title,
            message: "\(error)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: dismissButtonTitle,
            style: .default,
            handler: nil
        ))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
#endif
