import SwiftUI
import UIKit

/// An observable object that publishes the height of the keyboard.
@available(iOS 13.0.0, *)
@available(tvOS, unavailable)
fileprivate final class KeyboardReaderModel: ObservableObject {
    // MARK: Static
    
    static let shared = KeyboardReaderModel()
    
    // MARK: State
    
    @Published var keyboardHeight: CGFloat = 0
    
    // MARK: Implementation
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(notification:)),
            name: UIApplication.keyboardWillChangeFrameNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillChangeFrame(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        let keyboardInfo = getKeyboardNotificationInfo(userInfo: userInfo)
        
        withAnimation(.spring(response: keyboardInfo.animationDuration ?? 0, dampingFraction: 1)) {
            if keyboardInfo.endingFrame.height > 0 {
                keyboardHeight = UIScreen.main.bounds.height - keyboardInfo.endingFrame.minY
            } else {
                keyboardHeight = 0
            }
        }
    }
}

/// A container view that defines its content as a function of the height of the keyboard.
@available(iOS 13.0.0, *)
@available(tvOS, unavailable)
public struct KeyboardHeightReader<Content>: View where Content: View {
    @ObservedObject private var model = KeyboardReaderModel.shared
    
    public var content: (CGFloat) -> Content
    
    public init(@ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(model.keyboardHeight)
    }
    
}
