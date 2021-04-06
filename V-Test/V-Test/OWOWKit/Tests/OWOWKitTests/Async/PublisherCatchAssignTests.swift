import XCTest
import Combine

@available(iOS 13.0, tvOS 13.0, *)
class PublisherCatchAssignTests: XCTestCase {
    
    /// For testing the optional variant of the methods.
    var optionalError: TestError?
    var nonOptionalError: TestError = .notKaboom
    
    var disposables = Set<AnyCancellable>()
    
    enum TestError: Error {
        case kaboom
        case notKaboom
    }
    
    override func setUp() {
        optionalError = nil
        disposables = []
    }
    
    // MARK: Tests of optional variants
    
    func testCatchAssignWithoutError_optional() {
        let success = expectation(description: "Success")
        success.expectedFulfillmentCount = 10
        success.assertForOverFulfill = true
        
        (0..<10).publisher
            .setFailureType(to: TestError.self)
            .catchAssign(to: \PublisherCatchAssignTests.optionalError, on: self)
            .sink { _ in success.fulfill() }
            .store(in: &disposables)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(optionalError == nil)
    }
    
    func testCatchAssignWithError_optional() {
        let completionExpectation = expectation(description: "Completion")
        
        Fail(outputType: Void.self, failure: TestError.kaboom)
            .catchAssign(to: \PublisherCatchAssignTests.optionalError, on: self)
            .sink(receiveCompletion: { completion in
                XCTAssert(completion == .finished)
                completionExpectation.fulfill()
            }, receiveValue: {
                XCTFail()
            })
            .store(in: &disposables)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(optionalError == .kaboom)
    }
    
    func testWeakCatchAssignIsWeak_optional() {
        class TestClass {
            var error: TestError? {
                didSet {
                    XCTFail()
                }
            }
        }
        
        var test: TestClass? = .init()
        
        let subject = PassthroughSubject<Void, TestError>()
        let completionExpectation = expectation(description: "Error completion is needed")
        
        subject
            .weakCatchAssign(to: \.error, on: test!)
            .sink(receiveCompletion: { completion in
                XCTAssert(completion == .finished)
                completionExpectation.fulfill()
            }, receiveValue: {
                XCTFail()
            })
            .store(in: &disposables)
        
        test = nil
        
        subject.send(completion: .failure(.kaboom))
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    // MARK: Test of nonoptional variants
    
    func testCatchAssignWithoutError_nonOptional() {
        let success = expectation(description: "Success")
        success.expectedFulfillmentCount = 10
        success.assertForOverFulfill = true
        
        (0..<10).publisher
            .setFailureType(to: TestError.self)
            .catchAssign(to: \PublisherCatchAssignTests.nonOptionalError, on: self)
            .sink { _ in success.fulfill() }
            .store(in: &disposables)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(nonOptionalError == .notKaboom)
    }
    
    func testCatchAssignWithError_nonOptional() {
        let completionExpectation = expectation(description: "Completion")
        
        Fail(outputType: Void.self, failure: TestError.kaboom)
            .catchAssign(to: \PublisherCatchAssignTests.nonOptionalError, on: self)
            .sink(receiveCompletion: { completion in
                XCTAssert(completion == .finished)
                completionExpectation.fulfill()
            }, receiveValue: {
                XCTFail()
            })
            .store(in: &disposables)
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssert(nonOptionalError == .kaboom)
    }
    
    func testWeakCatchAssignIsWeak_nonOptional() {
        class TestClass {
            var error: TestError = .notKaboom {
                didSet {
                    XCTFail()
                }
            }
        }
        
        var test: TestClass? = .init()
        
        let subject = PassthroughSubject<Void, TestError>()
        let completionExpectation = expectation(description: "Error completion is needed")
        
        subject
            .weakCatchAssign(to: \.error, on: test!)
            .sink(receiveCompletion: { completion in
                XCTAssert(completion == .finished)
                completionExpectation.fulfill()
            }, receiveValue: {
                XCTFail()
            })
            .store(in: &disposables)
        
        test = nil
        
        subject.send(completion: .failure(.kaboom))
        
        waitForExpectations(timeout: 1, handler: nil)
    }

}
