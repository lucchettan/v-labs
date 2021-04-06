import SwiftUI
import UIKit

@available(iOS 13, *)
@available(tvOS, unavailable)
fileprivate struct PreferredStatusBarStyleView<Content: View>: View {
    /// The ui environment
    var environment: UIEnvironment? {
        OWOWKitConfiguration.appContext?.uiEnvironment
    }
    
    /// The content of the view.
    let content: Content
    
    /// The preferred status bar style of the view.
    let style: UIStatusBarStyle
    
    var body: some View {
        guard let environment = self.environment else {
            print("OWOWKit: ⚠️⚠️ Could not resolve UI environment. Did you register your app context?")
            
            return EmptyView()
                .erasedToAnyView()
        }
        
        return content.onAppear {
            environment.preferredStatusBarStyle = self.style
        }
        .onDisappear {
            environment.preferredStatusBarStyle = nil
        }
        .erasedToAnyView()
    }
}

@available(iOS 13, *)
@available(tvOS, unavailable)
extension View {
    /// Sets the preferred status bar style of the view. Available when the view is contained in a OWOW `HostingController`.
    public func preferredStatusBarStyle(_ style: UIStatusBarStyle) -> some View {
        return PreferredStatusBarStyleView(
            content: self,
            style: style
        )
    }
}
