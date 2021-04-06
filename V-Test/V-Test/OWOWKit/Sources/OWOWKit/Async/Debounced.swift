import Foundation

/// A debounced function / closure.
@dynamicCallable
public class Debounced {
    /// The closure to debounce.
    private var closure: () -> Void
    
    /// The debounce rate.
    public var timeInterval: Double
    
    /// When set to true, any outstanding debounced call is cancelled on deinit.
    public var cancelsOnDeinit: Bool
    
    /// The current timer.
    weak private var timer: Timer?
    
    /// Initialise a new debounced function.
    public init(timeInterval: Double, cancelsOnDeinit: Bool = true, closure: @escaping () -> Void) {
        self.timeInterval = timeInterval
        self.cancelsOnDeinit = cancelsOnDeinit
        self.closure = closure
    }
    
    /// Cancels any currently scheduled call.
    public func cancel() {
        timer?.invalidate()
        timer = nil
    }
    
    public func dynamicallyCall(withArguments: [Void]) {
        self.cancel()
        
        let closure = self.closure
        
        timer = .scheduledTimer(
        withTimeInterval: timeInterval,
        repeats: false
        ) { _ in
            closure()
        }
    }
    
    deinit {
        if self.cancelsOnDeinit {
            self.cancel()
        }
    }
}
