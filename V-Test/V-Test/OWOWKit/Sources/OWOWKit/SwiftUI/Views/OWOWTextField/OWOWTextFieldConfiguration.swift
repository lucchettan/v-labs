import SwiftUI

// MARK: UITextField property configuration

@available(iOS 13.0.0, *)
public protocol _TextFieldConfigurationItemProtocol {
    func apply(to field: OWOWUITextField)
}

@available(iOS 13.0.0, *)
public struct _TextFieldConfigurationItem<Value>: _TextFieldConfigurationItemProtocol {
    let keyPath: ReferenceWritableKeyPath<OWOWUITextField, Value>
    let value: Value
    
    @usableFromInline
    init(keyPath: ReferenceWritableKeyPath<OWOWUITextField, Value>, value: Value) {
        self.keyPath = keyPath
        self.value = value
    }
    
    public func apply(to field: OWOWUITextField) {
        let oldValue = field[keyPath: keyPath]
        field[keyPath: keyPath] = value
        
        // Support live-changing of the keyboard type
        if let oldValue = oldValue as? UIKeyboardType, let newValue = value as? UIKeyboardType, field.isFirstResponder, oldValue != newValue {
            field.reloadInputViews()
        }
    }
}

@available(iOS 13.0.0, *)
fileprivate struct TextFieldConfigurationKey: EnvironmentKey {
    static let defaultValue: [_TextFieldConfigurationItemProtocol] = []
}

@available(iOS 13.0.0, *)
internal extension EnvironmentValues {
    var textFieldConfiguration: [_TextFieldConfigurationItemProtocol] {
        get {
            return self[TextFieldConfigurationKey.self]
        }
        set {
            self[TextFieldConfigurationKey.self] = newValue
        }
    }
}

@available(iOS 13.0.0, *)
@usableFromInline
struct _TextFieldConfigurationModifier: ViewModifier {
    @Environment(\.textFieldConfiguration) var textFieldConfig
    
    var item: _TextFieldConfigurationItemProtocol
    
    @usableFromInline
    init(item: _TextFieldConfigurationItemProtocol) {
        self.item = item
    }
    
    @usableFromInline
    func body(content: Content) -> some View {
        var config = textFieldConfig
        config.append(item)
        return content.environment(\.textFieldConfiguration, config)
    }
}

@available(iOS 13.0.0, *)
public extension View {
    /// Set a configuration value for `key` on instances of `UITextField` that are wrapped by `OWOWTextField`.
    ///
    /// - Parameters:
    ///    - keyPath: The key path of the property to set.
    ///    - value: The value to set.
    @inlinable func textField<T>(_ keyPath: ReferenceWritableKeyPath<OWOWUITextField, T>, _ value: T) -> some View {
        return self.modifier(
            _TextFieldConfigurationModifier(item: _TextFieldConfigurationItem(keyPath: keyPath, value: value))
        )
    }
}

// MARK: Decoration height configuration

@available(iOS 13.0.0, *)
fileprivate struct OWOWTextFieldDecorationHeight: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

@available(iOS 13.0.0, *)
internal extension EnvironmentValues {
    var owowTextFieldDecorationHeight: CGFloat? {
        get {
            return self[OWOWTextFieldDecorationHeight.self]
        }
        set {
            self[OWOWTextFieldDecorationHeight.self] = newValue
        }
    }
}

@available(iOS 13.0.0, *)
public extension View {
    /// Sets the text field decoration height for the view hierarchy contained in `self`.
    ///
    /// When set, `OWOWTextField` uses this information to adjust scrolling behavior, so the field and it's decoration scroll into view when it becomes the first responder.
    /// If the text field is contained in a scroll view, it wil instruct the scroll view to scroll the area of this height, from the center of the text field, to be visible.
    func textField(decorationHeight: CGFloat) -> some View {
        return self.environment(\.owowTextFieldDecorationHeight, decorationHeight)
    }
}
