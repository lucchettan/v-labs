public struct Get: Requestable {
    public let method = HTTPMethod.get
    public let body = VoidBody()
    
    public init() {}
}
