public struct Post<Body: Encodable>: Requestable {
    public let method = HTTPMethod.post
    public var body: Body
    
    public init(body: Body) {
        self.body = body
    }
}

public extension Post where Body == VoidBody {
    init() {
        self.body = .init()
    }
}
