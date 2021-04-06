import Foundation
import Combine

extension URLSession {
    /// Returns a response publisher for the given request.
    ///
    /// - parameter request: The URLRequest to do.
    /// - parameter responseBody: The kind of response body to parse. It can normally be omited, but may be helpful to help the compiler if there is ambiguity.
    @available(iOS 13.0.0, *)
    public func responsePublisher<ResponseBody: Decodable>(
        for request: URLRequest,
        responseBody: ResponseBody.Type = ResponseBody.self
    ) -> AnyPublisher<Response<ResponseBody>, Error> {
        return self
            .dataTaskPublisher(for: request)
            .tryMap(Self.parseResponse)
            .mapError(URLRequestError.init)
            .mapError { error in
                switch error {
                case .otherError(let error):
                    return error
                default:
                    return error
                }
            }
            .handleEvents(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    OWOWKitConfiguration.logAPIError?(error, request)
                case .finished:
                    break
                }
            })
            .eraseToAnyPublisher()
    }
    
    private static func parseResponse<ResponseBody: Decodable>(
        data: Data,
        response: URLResponse
    ) throws -> Response<ResponseBody> {
        guard let response = response as? HTTPURLResponse else {
            throw URLRequestError.internalInconsistency
        }
        
        #if DEBUG
        print("⬇️ \(response.statusCode) \(response.url?.absoluteString ?? "") (\(data.count) bytes)")
        print(String(data: data, encoding: .utf8) ?? "")
        #endif
        
        guard 200..<300 ~= response.statusCode else {
            try OWOWKitConfiguration.throwAPIError(response, data)
            
            /// This should not happen: the error throwing function should always throw errors.
            throw URLRequestError.internalInconsistency
        }
        
        let decodedBody: ResponseBody
        
        if let type = ResponseBody.self as? VoidBody.Type {
            // swiftlint:disable:next force_cast
            decodedBody = type.init() as! ResponseBody
        } else if ResponseBody.self == String.self {
            guard let string = String(data: data, encoding: .utf8) else {
                throw URLRequestError.decodingError(
                    DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: [],
                            debugDescription: "OWOWKit expected UTF8 string but didn't find any"
                        )
                    )
                )
            }
            
            decodedBody = string as! ResponseBody
        } else {
            let decoder = OWOWKitConfiguration.jsonDecoder(for: ResponseBody.self)
            decodedBody = try decoder.decode(ResponseBody.self, from: data)
        }
        
        let wrappedResponse = Response(body: decodedBody, statusCode: response.statusCode)
        
        return wrappedResponse
    }
}
