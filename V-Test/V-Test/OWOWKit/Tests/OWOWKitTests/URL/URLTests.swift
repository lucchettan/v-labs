import XCTest
import Foundation

/// A mock protocol that is used by URLSession for testing our URLSession extensions.
fileprivate final class MockProtocol: URLProtocol {
    
    /// A dictionary containing response bodies.
    static var testURLs = [String: Data]()
    
    /// A closure that is executed for all URLRequests.
    static var requestValidator: (URLRequest) -> Void = { _ in }
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        var request = self.request
        
        // Convert stream to data
        if request.httpBody == nil, let stream = request.httpBodyStream {
            request.httpBody = Data(stream: stream)
        }
        
        Self.requestValidator(request)
        
        if let url = request.url {
            let statusCode: Int
            
            if let data = Self.testURLs[url.absoluteString] {
                statusCode = 200
                
                self.client?.urlProtocol(self, didLoad: data)
            } else {
                statusCode = 404
            }
            
            self.client?.urlProtocol(
                self,
                didReceive: HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "1.1", headerFields: ["Content-Type": "application/json"])!,
                cacheStoragePolicy: .notAllowed
            )
        }
        
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
}

fileprivate extension Data {
    init(stream: InputStream) {
        self.init()
        stream.open()
        defer { stream.close() }
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        while stream.hasBytesAvailable {
            let readCount = stream.read(buffer, maxLength: bufferSize)
            
            if readCount <= 0 {
                break
            }
            
            self.append(buffer, count: readCount)
        }
    }
}

final class URLTests: XCTestCase {
    
    let config = configure(URLSessionConfiguration.ephemeral) { config in
        config.protocolClasses = [MockProtocol.self]
    }
    
    lazy var urlSession = URLSession(configuration: config)
    
    override func tearDown() {
        MockProtocol.testURLs = [:]
        MockProtocol.requestValidator = { _ in }
    }
    
    // MARK: Testing the mock protocol
    
    func testMockProtocolIsUsedByURLSession() throws {
        let url = "https://localhost/kaas"
        let testData = Data("Foobarkaas".utf8)
        MockProtocol.testURLs[url] = testData
        
        let expectation = self.expectation(description: "URLRequest finished expectation")
        
        let request = try URLRequest(request: Get(), url: url)
        let task = urlSession.dataTask(with: request) { data, response, error in
            XCTAssertEqual(data, testData)
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            XCTAssertNil(error)
            
            expectation.fulfill()
        }
        task.resume()
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    // MARK: HTTP methods
    
    func doRequest<R: Requestable>(_ request: R, url: String = "https://localhost/kaas") throws {
        let urlRequest = try URLRequest(request: request, url: url)
        let task = urlSession.dataTask(with: urlRequest)
        task.resume()
    }
    
    func runRequestTest<R: Requestable>(_ request: R, validations: @escaping (URLRequest) -> Void) {
        let expectation = self.expectation(description: "URLRequest validated expectation")
        
        MockProtocol.requestValidator = { request in
            validations(request)
            
            expectation.fulfill()
        }
        
        XCTAssertNoThrow(try doRequest(request))
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testGetWithNoBody() {
        runRequestTest(Get()) { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertNil(request.httpBody)
            XCTAssertNil(request.allHTTPHeaderFields?["Content-Type"])
        }
    }
    
    func testPostWithJSON() {
        runRequestTest(Post(body: ["foo": "bar"])) { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.httpBody, Data(#"{"foo":"bar"}"#.utf8))
            XCTAssertEqual(request.allHTTPHeaderFields?["Content-Type"], "application/json; charset=utf-8")
        }
    }
    
    func testPostWithNoBody() {
        runRequestTest(Post()) { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertNil(request.httpBody)
            XCTAssertNil(request.allHTTPHeaderFields?["Content-Type"])
        }
    }
    
    func testDelete() {
        runRequestTest(Delete()) { request in
            XCTAssertEqual(request.httpMethod, "DELETE")
            XCTAssertNil(request.httpBody)
            XCTAssertNil(request.allHTTPHeaderFields?["Content-Type"])
        }
    }
    
}
