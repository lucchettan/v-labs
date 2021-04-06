import SwiftUI

/// The simplest generic implementation of `UIViewControllerRepresentable`.
@available(iOS 13, tvOS 13, *)
public struct RepresentedViewController<ViewController: UIViewController>: UIViewControllerRepresentable {
    
    /// The `UIViewController` that is represented.
    public var viewController: ViewController
    
    /// 🌷
    public init(_ viewController: ViewController) {
        self.viewController = viewController
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<RepresentedViewController<ViewController>>) -> ViewController {
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<RepresentedViewController<ViewController>>) { }
    
}
