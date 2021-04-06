#if canImport(UIKit)
import UIKit

public extension UIFont {
    /// Returns the system font for the given text `style`, adjusted for the given `weight`.
    ///
    /// - Parameter style: The text style to get a font for
    /// - Parameter weight: The requested font weight
    /// - Parameter size: If given, the given size will be scaled with `style` to the appropriate dynamic type text size.
    /// - Returns: A scaled `UIFont`
    static func preferredFont(forTextStyle style: TextStyle, weight: Weight, size: CGFloat? = nil) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: style)
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style)
        let font = UIFont.systemFont(ofSize: size ?? descriptor.pointSize, weight: weight)
        return metrics.scaledFont(for: font)
    }
}
#endif
