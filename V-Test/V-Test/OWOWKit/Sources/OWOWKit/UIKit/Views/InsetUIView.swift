import UIKit

/// A view that layouts its subviews with the given inset.
///
/// For performance reasons, do not prefer this class over manually adding an inset to a view. Only use if you need a wrapper view.
public final class InsetUIView<Content>: UIView where Content: UIView {
    
    lazy var topConstraint: NSLayoutConstraint = self.content.topAnchor.constraint(equalTo: self.topAnchor)
    lazy var leftConstraint: NSLayoutConstraint = self.content.leftAnchor.constraint(equalTo: self.leftAnchor)
    lazy var bottomConstraint: NSLayoutConstraint = self.bottomAnchor.constraint(equalTo: self.content.bottomAnchor)
    lazy var rightConstraint: NSLayoutConstraint = self.rightAnchor.constraint(equalTo: self.content.rightAnchor)
    
    /// The edge insets that are applied by the view.
    public var insets: UIEdgeInsets {
        get {
            return UIEdgeInsets(
                top: topConstraint.constant,
                left: leftConstraint.constant,
                bottom: bottomConstraint.constant,
                right: rightConstraint.constant
            )
        }
        set {
            topConstraint.constant = newValue.top
            leftConstraint.constant = newValue.left
            bottomConstraint.constant = newValue.bottom
            rightConstraint.constant = newValue.right
        }
    }
    
    /// The content view that is managed.
    private let content: Content
    
    public init(insets: UIEdgeInsets, content: Content) {
        self.content = content
        super.init(frame: .zero)
        
        self.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        
        self.insets = insets
        
        NSLayoutConstraint.activate([
            self.topConstraint,
            self.leftConstraint,
            self.bottomConstraint,
            self.rightConstraint
        ])
    }
    
    // MARK: - Trash
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
