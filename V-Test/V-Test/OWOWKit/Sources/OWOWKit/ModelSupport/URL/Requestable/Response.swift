public struct Response<Body> {
    public var body: Body
    public var statusCode: Int
    
    public init(body: Body, statusCode: Int) {
        self.body = body
        self.statusCode = statusCode
    }
}
