import UIKit
import SwiftUI
import Combine

/// A `UIHostingController` that uses the `environment` to set certain properties, such as the status bar color.
@available(iOS 13, *)
@available(tvOS, unavailable)
public final class HostingController<Content: View>: UIHostingController<Content> {
    
    // MARK: State
    
    /// The UI environment.
    let environment: UIEnvironment
    
    /// To store cancellables.
    var disposeBag = [AnyCancellable]()
    
    /// Keeps track if we did the setup in `viewWillAppear`.
    private var didSetup = false
    
    // MARK: Init
    
    /// Initialise a new `HostingController`.
    ///
    /// - parameter rootView: The root view of the hosting controller. Note that the environmentObject will not be automatically set on this view: you need to do this yourself.
    /// - parameter environment: The `UIEnvironment` instance.
    public init(rootView: Content, environment: UIEnvironment) {
        self.environment = environment
        super.init(rootView: rootView)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Set-up
    
    /// Set-up event listeners.
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !didSetup else { return }
        didSetup = true
        
        /// Listen to status bar appearance updates
        environment.$preferredStatusBarStyle.sink { [weak self] style in
            self?.statusBarStyle = style
            self?.setNeedsStatusBarAppearanceUpdate()
        }.store(in: &disposeBag)
    }
    
    var statusBarStyle: UIStatusBarStyle?
    
    /// Allow settings the status bar style from the environment.
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle ?? super.preferredStatusBarStyle
    }
}

