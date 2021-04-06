import UIKit

/// A navigation controller that forces hiding of the navigation bar.
open class NavigationBarHiddenNavigationController: UINavigationController {
    
    open override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(true, animated: animated)
    }
    
}
