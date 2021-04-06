import UIKit

/// A `UITextField` subclass that supports configuration of the placeholder text color.
@IBDesignable open class OWOWUITextField: UITextField {
    
    /// The color that is used to draw the placeholder text.
    @IBInspectable public var placeholderTextColor: UIColor?
    
    open override func drawPlaceholder(in rect: CGRect) {
        guard let attributedPlaceholder = self.attributedPlaceholder, let placeholderTextColor = placeholderTextColor else {
            super.drawPlaceholder(in: rect)
            return
        }
        
        let mutableString = NSMutableAttributedString(attributedString: attributedPlaceholder)
        mutableString.addAttribute(
            .foregroundColor,
            value: placeholderTextColor,
            range: NSRange(location: 0, length: mutableString.length)
        )
        mutableString.draw(in: rect)
    }
    
}
