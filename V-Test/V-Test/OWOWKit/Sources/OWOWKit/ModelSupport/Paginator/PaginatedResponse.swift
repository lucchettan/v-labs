public protocol PaginatedResponse: Codable {
    associatedtype Element
    
    var data: [Element] { get }
    var total: Int { get }
}
