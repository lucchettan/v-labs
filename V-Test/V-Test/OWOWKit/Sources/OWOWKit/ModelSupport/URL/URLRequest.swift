import Foundation
import Combine

extension URLRequest {
    
    /// Helper method to initialise a URLRequest.
    ///
    /// - parameter request: The OWOWKit request.
    /// - parameter url: The URL string. It will be prefixed by `baseURL`.
    /// - parameter parameters: The URL (query) parameters to use.
    /// - parameter headers: The headers to send.
    /// - parameter baseURL: The base URL to prefix before `url`. By default, the base URL configured in OWOWKit is used.
    /// - parameter criteria: Any OWOWKit criteria that should be applied to the request.
    public init<Request: Requestable>(
        request: Request,
        url: String,
        parameters: [String: String?] = [:],
        headers: [String: String] = [:],
        baseURL: String = OWOWKitConfiguration.baseURL,
        criteria: CriteriaSet = []
    ) throws {
        let url = try Self.makeURL(url: url, baseURL: baseURL, parameters: parameters, criteria: criteria)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        // Add the body if required
        let body = request.body
        if !(body is VoidBody) {
            let encoder = OWOWKitConfiguration.jsonEncoder(for: body)
            urlRequest.httpBody = try encoder.encode(body)
            
            #if DEBUG
            if let body = urlRequest.httpBody, let bodyString = String(data: body, encoding: .utf8) {
                print("⬆️ \(url.absoluteString) (\(body.count) bytes)")
                print(bodyString)
            }
            #endif
            
            urlRequest.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        
        // Add headers
        for header in headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Load criteria
        try urlRequest.apply(criteria: criteria)
        
        self = urlRequest
    }
    
    /// Builds the URL with the given parameters.
    private static func makeURL(
        url: String,
        baseURL: String,
        parameters: [String: String?],
        criteria: CriteriaSet
    ) throws -> URL {
        let fullURLString: String
        if baseURL.isEmpty {
            fullURLString = url
        } else {
            fullURLString = "\(baseURL)/\(url)"
        }
        
        // Construct the request
        guard var components: URLComponents = URLComponents(string: fullURLString) else {
            throw URLRequestError.invalidURL
        }
        
        if parameters.count > 0 {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        try components.apply(criteria: criteria)
        
        guard let url = components.url else {
            throw URLRequestError.invalidURL
        }
        
        return url
    }
    
}
