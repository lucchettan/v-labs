#if canImport(UIKit) && !os(watchOS)
import UIKit

extension CALayer {
    /// Applies a shadow with the given properties. Those properties can come from a Sketch file.
    public func applyShadow(
        color: UIColor,
        opacity: Float,
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat = 0) {
        self.shadowColor = color.cgColor
        self.shadowOpacity = opacity
        self.shadowOffset = CGSize(width: x, height: y)
        self.shadowRadius = blur / 2
        
        if spread == 0 {
            self.shadowPath = nil
        } else {
            let rect = bounds.insetBy(dx: -spread, dy: -spread)
            self.shadowPath = CGPath(rect: rect, transform: nil)
        }
    }
}
#endif
