import Foundation

/// Similar to using `?? ""`. Useful for creating a binding from a TextField to an optional property.
extension Optional where Wrapped == String {
    public var orEmpty: String {
        get {
            self ?? ""
        }
        set {
            self = newValue
        }
    }
}
