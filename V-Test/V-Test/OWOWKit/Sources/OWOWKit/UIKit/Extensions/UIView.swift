#if canImport(UIKit)
import UIKit

extension UIView {
    /// Returns the first superview of type `ViewType` in the superview chain, or `nil` if there isn't any.
    public func findSuperview<ViewType: UIView>(ofType type: ViewType.Type) -> ViewType? {
        return findTypeInChain(
            startingAt: self,
            keyPath: \.superview,
            lookingForType: type
        )
    }
    
    /// Returns the first parent responder of type `ResponderType` by walking up in the responder chain.
    public func findParentResponder<ResponderType: UIResponder>(ofType type: ResponderType.Type) -> ResponderType? {
        return findTypeInChain(
            startingAt: self,
            keyPath: \.next,
            lookingForType: type
        )
    }
    
    /// Returns the parent view controller of the view, if any.
    public var parentViewController: UIViewController? {
        return findParentResponder(ofType: UIViewController.self)
    }
}
#endif
