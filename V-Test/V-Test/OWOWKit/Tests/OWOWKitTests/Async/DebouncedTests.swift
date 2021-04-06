import XCTest

final class DebouncedTests: XCTestCase {
    func testDebouncedActuallyDebouncesWhenRapidlyCalling() {
        let once = expectation(description: "Should be called once")
        once.expectedFulfillmentCount = 1
        once.assertForOverFulfill = true
        
        let debounced = Debounced(timeInterval: 0.1) {
            once.fulfill()
        }
        
        DispatchQueue.main.async {
            debounced()
            debounced()
            debounced()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testDebouncedWithPause() {
        let called = expectation(description: "First call")
        called.expectedFulfillmentCount = 2
        called.assertForOverFulfill = true
        
        let debounced = Debounced(timeInterval: 0.1) {
            called.fulfill()
        }
        
        DispatchQueue.main.async {
            debounced()
            debounced()
            debounced()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
            Thread.sleep(forTimeInterval: 0.2)
            
            debounced()
            Thread.sleep(forTimeInterval: 0.05)
            debounced()
            Thread.sleep(forTimeInterval: 0.05)
            debounced()
            Thread.sleep(forTimeInterval: 0.05)
            debounced()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testCancelsOnDeinit() {
        let theExpectation = expectation(description: "Should never be called")
        theExpectation.isInverted = true
        
        var debounced: Debounced? = Debounced(timeInterval: 0.5) {
            theExpectation.fulfill()
        }
        
        debounced!()
        debounced!()
        debounced!()
        
        debounced = nil
        
        wait(for: [theExpectation], timeout: 1)
    }
}
