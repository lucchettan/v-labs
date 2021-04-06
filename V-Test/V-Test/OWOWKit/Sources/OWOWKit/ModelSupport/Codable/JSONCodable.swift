import Foundation

/// A type that specifies it's own JSON encoder
public protocol JSONEncodable {
    static var encoder: JSONEncoder { get }
}

/// A type that specifies it's own JSON decoder.
public protocol JSONDecodable {
    static var decoder: JSONDecoder { get }
}

/// A type that specifies it's own JSON encoder and decoder.
public typealias JSONCodable = JSONEncodable & JSONDecodable

extension OWOWKitConfiguration {
    /// Returns the `JSONEncoder` to use for the given `Encodable`.
    public static func jsonEncoder(for encodable: Encodable) -> JSONEncoder {
        if let encodable = encodable as? JSONEncodable {
            return type(of: encodable).encoder
        } else {
            return OWOWKitConfiguration.defaultJsonEncoder
        }
    }
    
    /// Returns the `JSONDecoder` to use for the given `Decodable`.
    public static func jsonDecoder(for decodable: Decodable.Type) -> JSONDecoder {
        if let decodable = decodable as? JSONDecodable.Type {
            return decodable.decoder
        } else {
            return OWOWKitConfiguration.defaultJsonDecoder
        }
    }
}
