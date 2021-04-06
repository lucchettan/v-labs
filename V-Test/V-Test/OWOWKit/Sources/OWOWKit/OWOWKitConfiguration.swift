import Foundation
import SwiftUI

/// Stores OWOWKit configuration parameters.
public enum OWOWKitConfiguration {
    /// A URL that will be prefixed before all URL requests.
    public static var baseURL = ""
    
    /// The default JSON Encoder.
    public static var defaultJsonEncoder = JSONEncoder()
    
    /// The default JSON Decoder.
    public static var defaultJsonDecoder = JSONDecoder()
    
    /// A closure that decodes API errors. It should then throw the appropriate error, that is applicable for the app.
    public static var throwAPIError: ((HTTPURLResponse, Data) throws -> Void) = { response, data in
        throw URLRequestError.serverErrorAndUnableToDecodeErrorBody(response, URLRequestError.errorThrowingFunctionNotAssigned)
    }
    
    /// Can be configured to log API level errors. Defaults to `nil`.
    public static var logAPIError: ((Error, URLRequest) -> Void)?
    
    // MARK: - App Context Registration
    
    /// The app context of your app.
    @available(iOS 13, tvOS 13, *)
    public static var appContext: AppContextProtocol?
    
    public static var perPageParameterName = "perPage"
    
    // MARK: - SwiftUI Modifier Configuration
    
    /// Configures the presentation of errors.
    /// See the default value for an example.
    ///
    /// To use this way of presenting errors, use the `showErrors` modifier on views.
    ///
    /// The closure accepts three parameters: The view on which the error is to be presented,
    /// the error itself, and an `isPresented` binding for use with alerts. The closure should
    /// return the input view, modified to present the error.
    @available(iOS 13, tvOS 13, *)
    public static var swiftUIErrorPresenter: (AnyView, Error, Binding<Bool>) -> AnyView = { content, error, isPresented in
        return content
            .alert(isPresented: isPresented) {
                Alert(
                    title: Text(verbatim: "Error"),
                    message: Text(verbatim: error.localizedDescription),
                    dismissButton: .cancel(Text(verbatim: "Dismiss"))
                )
            }
            .erasedToAnyView()
    }
}
