import SwiftUI
import UIKit

@available(iOS 13, tvOS 13, *)
public struct OWOWScrollView<Content: View>: View {
    
    @Environment(\.scrollViewConfiguration) private var scrollViewConfig
    
    let content: Content
    
    /// 🌷
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        RepresentedViewController(OWOWScrollViewController(configuration: scrollViewConfig, content: content))
    }
    
}

@available(iOS 13, tvOS 13, *)
fileprivate class OWOWScrollViewController<Content: View>: UIViewController {

    let configuration: [_ScrollViewConfigurationItemProtocol]
    let content: Content
    
    init(configuration: [_ScrollViewConfigurationItemProtocol], content: Content) {
        self.configuration = configuration
        self.content = content
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func loadView() {
        let scrollView = _OWOWScrollViewNativeType()
        scrollView.backgroundColor = .clear
        scrollView.isOpaque = false
        
        for configuration in self.configuration {
            configuration.apply(to: scrollView)
        }
        
        let hostingController = UIHostingController(rootView: content)
        hostingController.willMove(toParent: self)
        addChild(hostingController)
        scrollView.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        hostingController.view.isOpaque = false
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])
        
        self.view = scrollView
    }
    
}
