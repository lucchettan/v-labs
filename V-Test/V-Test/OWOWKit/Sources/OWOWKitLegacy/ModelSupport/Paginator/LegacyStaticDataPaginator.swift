import Foundation
import OWOWKit

/// A `Paginator` for mocking purposes.
public class StaticDataPaginator<Element>: Paginator {
    
    let data: [Element]
    
    public init(_ data: [Element]) {
        self.data = data
        onCountManager.publish(element: data.count)
    }
    
    enum Error: Swift.Error {
        case indexOutOfRange
    }
    
    /// Manages subscribers for the `onCount` event.
    private var onCountManager = CompletionManager<Int?>(oneTime: false)
    
    // MARK: Paginator
    
    public func get(index: Int) -> Future<Element> {
        guard data.indices ~= index else {
            return Future(error: Error.indexOutOfRange)
        }
        
        return Future(data[index])
    }
    
    public func get(page: Int) -> Future<[Element]> {
        guard page == 1 else {
            return Future(error: Error.indexOutOfRange)
        }
        
        return Future(data)
    }
    
    public func onCount(_ handler: @escaping (Int?) -> Void) -> (() -> Void) {
        return onCountManager.add(handler: handler)
    }
    
    public var criteria: CriteriaSet = [] {
        didSet {
            reload()
        }
    }
    
    public func reload() {
        onCountManager.publish(element: nil)
        DispatchQueue.main.async {
            self.onCountManager.publish(element: self.data.count)
        }
    }
    
    public func prefetch(indices: [Int]) {}
    
}
