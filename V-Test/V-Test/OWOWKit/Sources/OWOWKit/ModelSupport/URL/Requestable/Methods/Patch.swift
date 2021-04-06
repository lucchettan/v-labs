public struct Patch<Body: Encodable>: Requestable {
    public let method = HTTPMethod.patch
    public var body: Body
    
    public init(body: Body) {
        self.body = body
    }
}

public extension Patch where Body == VoidBody {
    init() {
        self.body = .init()
    }
}
