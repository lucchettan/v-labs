import Foundation

/// A set of criteria, that enforces the `multipleInstancesAllowed`.
public struct CriteriaSet: ExpressibleByArrayLiteral {
    /// Initialises a new `CriteriaSet` with the given elements.
    public init(_ elements: [Criteria]) {
        self.storage = elements
        self.cleanout()
    }
    
    /// `ExpressibleByArrayLiteral`
    public init(arrayLiteral elements: Criteria...) {
        self.init(elements)
    }
    
    // MARK: Mutations
    
    /// Add the given criteria.
    public mutating func add(_ criteria: Criteria) {
        storage.append(criteria)
        cleanout()
    }
    
    /// Removes all criteria of the given type.
    public mutating func remove<T>(ofType type: T.Type) where T: Criteria {
        storage.removeAll(where: { $0 is T })
    }
    
    // MARK: Getting the elements
    
    public func elements<T>(ofType type: T.Type) -> [T] {
        return storage.compactMap { element in
            guard let criteria = element as? T else {
                print("Warning: ignoring criteria \(element) because it is incompatible with \(T.self)")
                return nil
            }
            
            return criteria
        }
    }
    
    // MARK: Private
    
    /// The stored criteria.
    private var storage: [Criteria]
    
    /// Removes duplicate instances of criteria that have `multipleInstancesAllowed` set to false.
    private mutating func cleanout() {
        var finalCriteria = [Criteria]()
        
        // Loop in reverse, because we want to keep the unique criteria that are latest in the array.
        for criteria in self.storage.reversed() {
            guard criteria.multipleInstancesAllowed || !finalCriteria.contains(where: { type(of: $0) == type(of: criteria) }) else {
                continue
            }
            
            finalCriteria.append(criteria)
        }
        
        self.storage = finalCriteria.reversed()
    }
}

extension CriteriaSet: URLRequestCriteria {
    public var multipleInstancesAllowed: Bool {
        return true
    }
    
    public func add(to components: inout URLComponents) throws {
        for element in self.elements(ofType: URLRequestCriteria.self) {
            try element.add(to: &components)
        }
    }
    
    public func add(to request: inout URLRequest) throws {
        for element in self.elements(ofType: URLRequestCriteria.self) {
            try element.add(to: &request)
        }
    }
}
