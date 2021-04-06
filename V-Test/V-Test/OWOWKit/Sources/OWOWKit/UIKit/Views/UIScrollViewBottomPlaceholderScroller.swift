#if canImport(UIKit)
import UIKit

/// For the lack of a better name, instances of `UIScrollViewBottomPlaceholderScroller` manages a view that sits
/// behind a table view (in the same coordinate space).
///
/// An instance of this class will manage the views `isHidden`, `transform` and `alpha` properties. When scrolling, the alpha
/// will be controlled to create a fade-in effect at the bottom of the scroll view, and the transform will be adjusted
/// so the placeholder view slides in from the bottom.
///
/// You can either call the `update` method yourself, or assign the instance as delegate to the scroll view.
public final class UIScrollViewBottomPlaceholderScroller<ManagedView: UIView>: NSObject, UIScrollViewDelegate {
    
    /// The scroll view.
    public let scrollView: UIScrollView
    
    /// The placeholder that is controlled by the instance.
    public let managedView: ManagedView
    
    /// We might privately want to update this value without calling `update`, so we have a separate stored property.
    private var _mayShowView = true
    
    /// When set to false, the view will always be hidden.
    public var mayShowView: Bool {
        get {
            return _mayShowView
        }
        set {
            _mayShowView = newValue
            update()
        }
    }
    
    public func setMayShowView(_ value: Bool, animated: Bool) {
        guard value != self.mayShowView else {
            return
        }
        guard animated else {
            self.mayShowView = value
            return
        }
        
        /// Slide in from the bottom and fade in if showing
        if value {
            managedView.alpha = 0
            managedView.transform = .init(
                translationX: 0,
                y: 50
            )
            
            UIView.animate(withDuration: 0.5) {
                self.mayShowView = value
            }
        } else {
            self._mayShowView = value
            self.forceUpdate(mayHide: false)
            
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.managedView.alpha = 0
            })
        }
    }
    
    public init(scrollView: UIScrollView, managedView: ManagedView) {
        self.scrollView = scrollView
        self.managedView = managedView
        
        super.init()
    }
    
    /// Updates the `alpha` and `transform` of `managedView`.
    public func update() {
        guard mayShowView else {
            managedView.isHidden = true
            return
        }
        
        self.forceUpdate(mayHide: true)
    }
    
    private func forceUpdate(mayHide: Bool) {
        let maximumVerticalOffset = max(scrollView.contentSize.height + scrollView.adjustedContentInset.bottom - scrollView.frame.height, -scrollView.adjustedContentInset.top)
        
        let triggerPointFromBottom = scrollView.frame.height / 2
        
        /// The first point at which the placeholder becomes slightly visible:
        let startingPointVerticalOffset = maximumVerticalOffset - triggerPointFromBottom
        
        let currentVerticalOffset = scrollView.contentOffset.y
        
        guard currentVerticalOffset > startingPointVerticalOffset else {
            managedView.isHidden = mayHide
            return
        }
        
        managedView.isHidden = false
        let adjustedOffset = currentVerticalOffset - startingPointVerticalOffset
        managedView.alpha = adjustedOffset / triggerPointFromBottom
        managedView.transform = .init(translationX: 0, y: 250 * (1 - adjustedOffset / triggerPointFromBottom))
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.update()
    }
    
}
#endif
