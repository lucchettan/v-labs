import UIKit
import Combine

/// A class that manages UI enviroment features not supported by SwiftUI, like the status bar style.
@available(iOS 13, *)
@available(tvOS, unavailable)
public class UIEnvironment: ObservableObject {
    public init() {}
    
    /// The current preferred status bar style.
    @Published public var preferredStatusBarStyle: UIStatusBarStyle?
    
    /// When set to `true`, functionality for going back is disabled.
    @Published public var theresNoGoingBack = false
    
    /// The token of the view that set the current preferred status bar style.
    internal var preferredStatusBarStyleSourceToken: Int?
    
    /// The next token to be returned by `getToken`.
    private static var nextToken = 0
    
    /// Returns a new token to identify change sources.
    internal static func getToken() -> Int {
        defer { nextToken += 1 }
        return nextToken
    }
    
    var _popToRoot: (Bool) -> [UIViewController]? = { _ in nil }
    var _endEditing: (Bool) -> Bool = { _ in false }
    
    public func endEditing(force: Bool) {
        _ = _endEditing(force)
    }
    
    /// Pops to the root view.
    public func popToRoot(animated: Bool) {
        _ = _popToRoot(animated)
    }
}

