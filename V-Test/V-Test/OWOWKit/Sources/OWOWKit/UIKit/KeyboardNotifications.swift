import UIKit

@available(tvOS, unavailable)
extension UIView {
    /// Animate changes to one or more views using the specified keyboard notification userInfo to determine the animation curve and duration.
    ///
    /// - parameter userInfo: The value of `userInfo` on the keyboard `Notification`
    /// - parameter animations: A closure containing the changes to commit to the views. This is where you programmatically change any animatable properties of the views in your view hierarchy.
    /// - parameter completion: A closure to be executed when the animation sequence ends. This closure has no return value and takes a single Bool argument that indicates whether or not the animations actually finished before the completion handler was called. If the duration of the animation is 0, this block is performed at the beginning of the next run loop cycle.
    public static func animate(withKeyboardNotification notification: Notification, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        let keyboardInfo: KeyboardInfo?
        
        if let userInfo = notification.userInfo {
            keyboardInfo = getKeyboardNotificationInfo(userInfo: userInfo)
        } else {
            keyboardInfo = nil
        }
        
        let curve = keyboardInfo?.animationCurve ?? .easeInOut
        let duration = keyboardInfo?.animationDuration ?? 0
        
        UIView.animate(withDuration: duration, delay: 0, options: curve.animationOption, animations: animations, completion: completion)
    }
}

public typealias KeyboardInfo = (beginFrame: CGRect, endingFrame: CGRect, animationCurve: UIView.AnimationCurve?, animationDuration: Double?)

/// Takes the `Notification.userInfo` value of a keyboard notification and extracts the related values from it.
@available(tvOS, unavailable)
public func getKeyboardNotificationInfo(userInfo: [AnyHashable: Any]) -> KeyboardInfo {
    let animationCurveNumber = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue
    let animationCurve: UIView.AnimationCurve?
    
    if let animationCurveNumber = animationCurveNumber {
        animationCurve = UIView.AnimationCurve(rawValue: animationCurveNumber)
    } else {
        animationCurve = nil
    }
    
    return (
        beginFrame: (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero,
        endingFrame: (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero,
        animationCurve: animationCurve,
        animationDuration: (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
    )
}

fileprivate extension UIView.AnimationCurve {
    /// Returns the animation option related to this animation curve
    var animationOption: UIView.AnimationOptions {
        return UIView.AnimationOptions(rawValue: UInt(self.rawValue) << 16)
    }
}
