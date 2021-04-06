import SwiftUI
import UIKit
import Combine

/// A view controller that fixes issues with SwiftUI navigation.
@available(iOS 13, *)
@available(tvOS, unavailable)
open class NavigationFixViewController: UIViewController {
    
    var uiEnvironment: UIEnvironment
    
    public init(uiEnvironment: UIEnvironment) {
        self.uiEnvironment = uiEnvironment
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) { nil }
    
    private lazy var screenEdgePanGestureRecognizerDelegate = ScreenEdgePanGestureRecognizerDelegate(
        navigationController: self.navigationController!,
        uiEnvironment: self.uiEnvironment
    )
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let navigationVc = navigationController else { return }
        
        uiEnvironment._popToRoot = navigationVc.popToRootViewController
        uiEnvironment._endEditing = navigationVc.view.endEditing
        
        guard let recognizer = navigationVc.interactivePopGestureRecognizer, recognizer.delegate !== screenEdgePanGestureRecognizerDelegate else {
            return
        }
        
        screenEdgePanGestureRecognizerDelegate.originalDelegate = recognizer.delegate
        recognizer.delegate = screenEdgePanGestureRecognizerDelegate
    }
    
    // MARK: ScreenEdgePanGestureRecognizerDelegate
    
    private final class ScreenEdgePanGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
        weak var navigationController: UINavigationController!
        var uiEnvironment: UIEnvironment
        var originalDelegate: UIGestureRecognizerDelegate?
        
        init(navigationController: UINavigationController, uiEnvironment: UIEnvironment) {
            self.navigationController = navigationController
            self.uiEnvironment = uiEnvironment
        }
        
        // MARK: UIGestureRecognizerDelegate
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            _ = originalDelegate?.gestureRecognizerShouldBegin?(gestureRecognizer)
            return navigationController.viewControllers.count > 1
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            _ = originalDelegate?.gestureRecognizer?(gestureRecognizer, shouldReceive: touch)
            return !uiEnvironment.theresNoGoingBack
        }
        
        // MARK: Objective C Selector Forwarding
        
        public override func responds(to aSelector: Selector!) -> Bool {
            return super.responds(to: aSelector) || originalDelegate?.responds(to: aSelector) ?? false
        }
        
        public override func forwardingTarget(for aSelector: Selector!) -> Any? {
            if super.responds(to: aSelector) {
                return self
            } else {
                return originalDelegate
            }
        }
    }
    
}

