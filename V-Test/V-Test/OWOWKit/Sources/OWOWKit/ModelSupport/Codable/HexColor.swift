import UIKit

extension UIColor {
    public convenience init(hex: UInt32, useAlpha alphaChannel: Bool = false) {
        let mask = UInt32(0xFF)
        
        let rawRed = hex >> (alphaChannel ? 24 : 16) & mask
        let rawGreen = hex >> (alphaChannel ? 16 : 8) & mask
        let rawBlue = hex >> (alphaChannel ? 8 : 0) & mask
        let rawAlpha = alphaChannel ? hex & mask : 255
        
        let red = CGFloat(rawRed) / 255
        let green = CGFloat(rawGreen) / 255
        let blue = CGFloat(rawBlue) / 255
        let alpha = CGFloat(rawAlpha) / 255
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public convenience init(hexString: String) {
        var hexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }
        
        let scanner = Scanner(string: hexString)
        
        if #available(iOS 13.0, *) {
            if let color = scanner.scanUInt64(representation: .hexadecimal) {
                self.init(hex: UInt32(color), useAlpha: hexString.count > 7)
            } else {
                self.init(hex: 0x000000)
            }
        } else {
            var color: UInt32 = 0
            
            if scanner.scanHexInt32(&color) {
                self.init(hex: color, useAlpha: hexString.count > 7)
            } else {
                self.init(hex: 0x000000)
            }
        }
    }
}

extension UIColor {
    
    /// Returns the hex string for the color. Does not support the alpha channel.
    public var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format: "#%06x", rgb)
    }
    
}

public struct HexColor: Codable, ExpressibleByStringLiteral, Hashable {
    
    /// The underlying color
    public let color: UIColor
    
    /// Initialise the `HexColor` with the given color to wrap.
    public init(color: UIColor) {
        self.color = color
    }
    
    /// `Decodable` implementation.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hexString = try container.decode(String.self)
        color = UIColor(hexString: hexString)
    }
    
    /// `Encodable` implementation.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let hexString = color.hexString
        try container.encode(hexString)
    }
    
    /// `ExpressibleByStringLiteral` implementation.
    public init(stringLiteral value: String) {
        color = UIColor(hexString: value)
    }
    
}
