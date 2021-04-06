import Foundation
import OWOWKit

public enum URLOperationError: Error {
    case invalidURL
}

/// A shared operation queue, usable for generic network requests.
fileprivate let _sharedQueue = OperationQueue()

/// An `Operation` subclass that encapsulates the work for doing an URL request.
public final class URLOperation<Request: Requestable, ResponseBody: Decodable>: Operation {
    
    /// A shared operation queue, usable for generic network requests.
    static var sharedQueue: OperationQueue { return _sharedQueue }
    
    // MARK: State management
    enum State {
        case ready
        case executing
        case cancelled
        case finished(Response<ResponseBody>)
        case error(Error)
        
        var kvoProperty: String {
            switch self {
            case .ready: return "isReady"
            case .executing: return "isExecuting"
            case .cancelled, .finished, .error: return "isFinished"
            }
        }
    }
    
    /// The state of the `URLOperation`.
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.kvoProperty)
            
            if newValue.kvoProperty != state.kvoProperty {
                willChangeValue(forKey: state.kvoProperty)
            }
        }
        didSet {
            didChangeValue(forKey: oldValue.kvoProperty)
            
            if oldValue.kvoProperty != state.kvoProperty {
                didChangeValue(forKey: state.kvoProperty)
            }
            
            switch state {
            case .finished(let result):
                completionManager.publish(element: .success(result))
            case .error(let error):
                completionManager.publish(element: .failure(error))
            default: break
            }
        }
    }
    
    public typealias Result = Swift.Result<Response<ResponseBody>, Error>
        
    // MARK: Properties
    
    /// The completion manager
    private let completionManager = CompletionManager<Result>()
    
    /// The base URL to use.
    private let baseURL: String
    
    /// The URL to request.
    private let url: String
    
    /// The request.
    private let request: Request
    
    /// The URL session.
    private let session: URLSession
    
    /// Query string parameters.
    private let parameters: [String: String?]
    
    /// HTTP Headers
    private let headers: [String: String]
    
    /// The running URL session task, if any.
    private var task: URLSessionTask?
    
    /// The criteria to apply
    private let criteria: CriteriaSet
    
    // MARK: Init
    
    /// Initialises a new URLOperation with the given parameters.
    public init(
        // note: when changing these default values, make sure to adapt the convenience initializer at the bottom of this file also
        url: String,
        request: Request,
        parameters: [String: String?] = [:],
        headers: [String: String] = OWOWKitLegacyConfiguration.defaultHTTPRequestHeaders,
        session: URLSession = URLSession.shared,
        baseURL: String = OWOWKitConfiguration.baseURL,
        criteria: CriteriaSet = []
    ) {
        self.url = url
        self.baseURL = baseURL
        self.session = session
        self.parameters = parameters
        self.headers = headers
        self.request = request
        self.criteria = criteria
    }
    
    // MARK: Main
    override public func main() {
        do {
            try doRequest()
        } catch {
            self.state = .error(error)
        }
    }
    
    private func doRequest() throws {
        let url = try makeURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = self.request.method.rawValue
        
        // Add the body if required
        let body = self.request.body
        if !(body is VoidBody) {
            let encoder = OWOWKitConfiguration.jsonEncoder(for: body)
            urlRequest.httpBody = try encoder.encode(body)
            urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        
        // Add configured headers
        for header in self.headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Load criteria
        try urlRequest.apply(criteria: self.criteria)
        
        let task = session.dataTask(with: urlRequest, completionHandler: self.dataTaskHandler)
        self.task = task
        
        task.resume()
    }
    
    private func dataTaskHandler(responseData: Data?, response: URLResponse?, error: Error?) {
        do {
            #if swift(>=5.1)
            let body: ResponseBody = try Self.decodableResponseHandler(
                responseData: responseData,
                response: response,
                responseError: error
            )
            #else
            let body: ResponseBody = try URLOperation<Request, ResponseBody>.decodableResponseHandler(
                responseData: responseData,
                response: response,
                responseError: error
            )
            #endif
            
            let httpResponse = response as? HTTPURLResponse
            
            let wrappedResponse = Response(body: body, statusCode: httpResponse?.statusCode ?? -1)
            
            if case .cancelled = self.state {
                /// it is invalid to transition from a cancelled state to another state
                return
            }
            
            self.state = .finished(wrappedResponse)
        } catch {
            if case .cancelled = self.state {
                /// it is invalid to transition from a cancelled state to another state
                return
            }
            
            self.state = .error(error)
        }
    }
    
    private static func decodableResponseHandler<R: Decodable>(responseData: Data?, response: URLResponse?, responseError: Error?) throws -> R {
        if let responseError = responseError {
            throw responseError
        }
        
        guard let response = response as? HTTPURLResponse else {
            throw APIError.internalInconsistency
        }
        
        guard let responseData = responseData else {
            throw APIError.missingResponseData
        }
        
        if response.statusCode == 403 {
            throw APIError.forbiddenAccess
        }
        
        guard 200..<300 ~= response.statusCode else {
            try OWOWKitConfiguration.throwAPIError(response, responseData)
            
            /// This should not happen: the error throwing function should always throw errors.
            throw APIError.internalInconsistency
        }
        
        if let type = R.self as? VoidBody.Type {
            // Don't try to decode VoidBody as JSON
            // swiftlint:disable:next force_cast
            return type.init() as! R
        } else if R.self == Data.self {
            // Don't try to decocde Data as JSON, but return the response data instead
            // swiftlint:disable:next force_cast
            return responseData as! R
        }
        
        let decoder = OWOWKitConfiguration.jsonDecoder(for: R.self)
        return try decoder.decode(R.self, from: responseData)
    }
    
    /// Generates the URL for the request.
    private func makeURL() throws -> URL {
        let fullURLString: String
        if baseURL.isEmpty {
            fullURLString = url
        } else {
            fullURLString = "\(baseURL)/\(url)"
        }
        
        // Construct the request
        guard var components: URLComponents = URLComponents(string: fullURLString) else {
            throw URLOperationError.invalidURL
        }
        
        if parameters.count > 0 {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        try components.apply(criteria: criteria)
        
        guard let url = components.url else {
            throw URLOperationError.invalidURL
        }
        
        return url
    }
    
    // MARK: Completion management
    
    /// Executes the given function when the operation completes.
    ///
    /// - returns: A cancel function. When called, the completion handler is unregistered.
    public func onComplete(handler: @escaping (Result) -> Void) -> (() -> Void) {
        return completionManager.add(handler: handler)
    }
    
    /// Returns a `Future` that will complete with the result of the operation, executed on the main queue.
    public func executeOnSharedQueue() -> Future<Response<ResponseBody>> {
        #if swift(>=5.1)
        Self.sharedQueue.addOperation(self)
        #else
        URLOperation<Request, ResponseBody>.sharedQueue.addOperation(self)
        #endif
        
        let promise = Promise<Response<ResponseBody>>()
        _ = self.onComplete { result in
            promise.fulfill(result)
            
            if case .failure(let error) = result {
                print("[URLOperation] Request failure: \(error)")
            }
        }
        return promise.futureResult
    }
    
    // MARK: Operation overrides
    override public func start() {
        guard !isCancelled else {
            state = .cancelled
            return
        }
        
        if !isExecuting {
            state = .executing
        }
        
        main()
    }
    
    override public func cancel() {
        super.cancel()
        
        state = .cancelled
        task?.cancel()
    }
    
}

extension URLOperation where Request == Get {
    
    /// Initialise a new URLOperation for a GET request.
    public convenience init(
        // note: when changing these default values, make sure to adapt the convenience initializer at the declaration of URLOperation also
        url: String,
        parameters: [String: String?] = [:],
        headers: [String: String] = OWOWKitLegacyConfiguration.defaultHTTPRequestHeaders,
        session: URLSession = URLSession.shared,
        baseURL: String = OWOWKitConfiguration.baseURL,
        criteria: CriteriaSet = []
    ) {
        self.init(
            url: url,
            request: Get(),
            parameters: parameters,
            headers: headers,
            session: session,
            baseURL: baseURL,
            criteria: criteria
        )
    }
    
}
