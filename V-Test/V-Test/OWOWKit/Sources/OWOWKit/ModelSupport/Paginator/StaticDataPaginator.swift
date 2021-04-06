import Foundation
import Combine

/// A `Paginator` for mocking purposes.
@available(iOS 13, *)
public class StaticDataPaginator<Element>: Paginator {
    let data: [Element]
    public let count: CurrentValueSubject<Int?, Never>
    
    public enum Error: Swift.Error {
        case indexOutOfRange
    }
    
    public init(_ data: [Element]) {
        self.data = data
        self.count = CurrentValueSubject<Int?, Never>(data.count)
    }
    
    public func get(index: Int) -> AnyPublisher<Element, Swift.Error> {
        guard data.indices ~= index else {
            return Fail(error: Error.indexOutOfRange)
                .eraseToAnyPublisher()
        }
        
        return Just(data[index])
            .setFailureType(to: Swift.Error.self)
            .eraseToAnyPublisher()
    }
    
    public var criteria: CriteriaSet = []
    
    public func reload() {
        self.count.value = nil
        
        DispatchQueue.main.async {
            self.count.value = self.data.count
        }
    }
    
    public func prefetch(indices: [Int]) {}
    
    public func forEach(_ body: @escaping (Element) throws -> Void) -> AnyPublisher<Void, Swift.Error> {
        return Future { fulfill in
            do {
                try self.data.forEach(body)
                fulfill(.success(()))
            } catch {
                fulfill(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
