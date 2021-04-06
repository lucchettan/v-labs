import Foundation

public enum APIError: Error {
    case internalInconsistency
    case unexpectedStatusCode(HTTPURLResponse)
    case missingResponseData
    case forbiddenAccess
    case errorThrowingFunctionNotAssigned
    
    /// An error occured while performing or parsing the request. In addition to the error that occured, we were unable to parse the error.
    case unableToDecodeError(HTTPURLResponse, Error)
    
    public var localizedDescription: String {
        switch self {
        case .internalInconsistency: return "An internal inconsistency occurred"
        case .unexpectedStatusCode(let response): return "The server unexpectedly responded with status code \(response.statusCode)"
        case .missingResponseData: return "We server didn't respond with useful data"
        case .unableToDecodeError: return "The server replied with an error, and we weren't able to understand the error"
        case .forbiddenAccess: return "Access to the requested URL is Forbidden for some reason"
        case .errorThrowingFunctionNotAssigned: return "An error throwing function was not assigned by the app integrating OWOWKit"
        }
    }
}
