import Combine

/// The protocol your app context type must conform to to.
@available(iOS 13, *)
@available(tvOS, unavailable)
public protocol AppContextProtocol: class {
    /// The UI environment of your app.
    var uiEnvironment: UIEnvironment { get }
}
