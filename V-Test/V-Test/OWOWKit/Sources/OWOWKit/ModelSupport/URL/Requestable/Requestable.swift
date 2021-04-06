public protocol Requestable {
    associatedtype Body: Encodable
    
    var method: HTTPMethod { get }
    var body: Body { get }
}
