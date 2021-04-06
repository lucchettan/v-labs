public struct Delete: Requestable {
    public let method = HTTPMethod.delete
    public let body = VoidBody()
    
    public init() {}
}
