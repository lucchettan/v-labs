import Foundation

public enum URLRequestError: Error, LocalizedError, CustomStringConvertible, CustomNSError {
    case networkError(URLError)
    case decodingError(DecodingError)
    case otherError(Error)
    case internalInconsistency
    case errorThrowingFunctionNotAssigned
    case serverErrorAndUnableToDecodeErrorBody(HTTPURLResponse, Error)
    case invalidURL
    
    init(error: Error) {
        if let error = error as? URLRequestError {
            self = error
        } else if let error = error as? URLError {
            self = .networkError(error)
        } else if let error = error as? DecodingError {
            self = .decodingError(error)
        } else {
            self = .otherError(error)
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let urlError):
            return "Network Error – " + urlError.localizedDescription
        case .decodingError(let decodingError):
            return decodingError.localizedDescription
        case .otherError(let error):
            return error.localizedDescription
        case .internalInconsistency:
            return "Internal inconsistency"
        case .errorThrowingFunctionNotAssigned:
            return "Error throwing function not assigned"
        case .serverErrorAndUnableToDecodeErrorBody(let response, let error):
            return "Server responded with \(response.statusCode) – unable to decode error: \(error.localizedDescription)"
        case .invalidURL:
            return "The URL is invalid"
        }
    }
    
    public var description: String {
        return "OWOWKit.URLRequestError: \(self.localizedDescription)"
    }
    
    public var underlyingError: Error? {
        switch self {
        case .networkError(let error): return error
        case .decodingError(let error): return error
        case .otherError(let error): return error
        case .serverErrorAndUnableToDecodeErrorBody(_, let error): return error
        default: return nil
        }
    }
    
    public var errorUserInfo: [String : Any] {
        return (underlyingError as NSError?)?.userInfo ?? ["description": errorDescription ?? "nil"]
    }
    
    public static var errorDomain: String {
        return "OWOWKitError"
    }
    
    public var errorCode: Int {
        if let underlyingCode = (underlyingError as NSError?)?.code {
            return underlyingCode
        }
        
        switch self {
        case .networkError: return 1
        case .decodingError: return 2
        case .otherError: return 3
        case .internalInconsistency: return 4
        case .errorThrowingFunctionNotAssigned: return 5
        case .serverErrorAndUnableToDecodeErrorBody: return 6
        case .invalidURL: return 7
        }
    }
}
