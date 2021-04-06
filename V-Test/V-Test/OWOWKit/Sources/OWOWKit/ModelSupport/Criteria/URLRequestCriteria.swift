import Foundation

/// A criteria that can be used to filter URL requests.
public protocol URLRequestCriteria: Criteria {
    /// Configures the given `URLRequest` with the criteria.
    /// A default implementation that does nothing is provided for criteria that only need to adjust the URL components.
    func add(to request: inout URLRequest) throws
    
    /// Configures the given `URLComponents` with the criteria.
    /// A default implementation that does nothing is provided for criteria that only need to adjust the URL request.
    func add(to components: inout URLComponents) throws
}

extension URLRequest {
    /// Applies the given criteria to the request.
    public mutating func apply(criteria: URLRequestCriteria) throws {
        try criteria.add(to: &self)
    }
}

extension URLComponents {
    /// Applies the given criteria to the URL components.
    public mutating func apply(criteria: URLRequestCriteria) throws {
        try criteria.add(to: &self)
    }
}

extension URLRequestCriteria {
    public func add(to request: inout URLRequest) {}
    public func add(to components: inout URLComponents) {}
}
