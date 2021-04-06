public struct Put<Body: Encodable>: Requestable {
    public let method = HTTPMethod.put
    public var body: Body
    
    public init(body: Body) {
        self.body = body
    }
}

public extension Put where Body == VoidBody {
    init() {
        self.body = .init()
    }
}
