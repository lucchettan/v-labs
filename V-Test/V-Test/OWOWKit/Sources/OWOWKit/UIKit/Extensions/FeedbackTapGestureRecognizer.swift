#if canImport(UIKit) && !os(watchOS)
import UIKit

open class FeedbackTapGestureRecognizer: UITapGestureRecognizer {
    private var previousAlpha: CGFloat?
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        defer {
            super.touchesBegan(touches, with: event)
        }
        
        guard let view = view else { return }
        
        if previousAlpha == nil {
            previousAlpha = view.alpha
        }
        
        view.alpha = max(0.1, view.alpha - 0.3)
    }
    
    override open func reset() {
        defer {
            super.reset()
        }
        
        guard let view = view, let previousAlpha = previousAlpha else {
            return
        }
        
        view.alpha = previousAlpha
    }
}
#endif
