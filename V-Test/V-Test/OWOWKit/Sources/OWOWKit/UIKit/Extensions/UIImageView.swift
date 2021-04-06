#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UIImageView {
    /// Sets the content mode of the receiver to `other` if the image size is greater than the size of the receiver.
    /// Sets the content mode to `center` if the image size is smaller than or equal to the size of the receiver.
    public func setContentModeCenter(or other: UIView.ContentMode) {
        if let size = image?.size, size.width > bounds.width || size.height > bounds.height {
            contentMode = other
        } else {
            contentMode = .center
        }
    }
}
#endif
