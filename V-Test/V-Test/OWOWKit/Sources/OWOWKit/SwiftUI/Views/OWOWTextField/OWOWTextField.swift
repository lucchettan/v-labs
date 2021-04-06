import SwiftUI
import Combine

/// A text field that wraps `UITextField` to overcome the shortcomings of Apples `TextField`/`SecureField`.
///
/// ## Configuring `UITextField` properties
///
/// Properties of the wrapped `UITextField` can be configured using the `textField(...)` modifier. Configuration
/// is handled through the environment. For example, to configure an `OWOWTextField` with red text:
///
/// ```
/// OWOWTextField(text: $text)
///     .textField(\.textColor, .red)
/// ```
///
/// ## hasFocus binding
///
/// The initializer of `OWOWTextField` allows passing a `hasFocus` binding. By setting the bound value to `true`,
/// it is possible to programatically make the text field gain focus.
///
/// ## hasFocus preference
///
/// Instances of `OWOWTextField` also publish their focus state as a preference, using `HasFocusPreferenceKey`.
/// One use case where this might be useful is for changing the decoration of a field based on if it has focus. A generic field
/// decoration view could listen for changes to `HasFocusPreferenceKey` and update the appearance accordingly.
///
/// ## Scroll view interaction
///
/// By default, text fields automatically adjust the content offset of a parent scroll view, so the text field becomes visible when it gains
/// focus. However, sometimes it is desirable to adjust the scroll offset so additional elements also become visible. This use
/// case is supported by means of the `textField(decorationHeight:)` modifier. When applied on a tree of views,
/// `OWOWTextField`s inside the tree will adjust their scrolling behavior to accomodate the extra height.
///
/// ## OWOWTextFieldStyle
///
/// Types implementing `OWOWTextFieldStyle` can style a text field. See the documentation on `OWOWTextFieldStyle` for
/// more information.
@available(iOS 13.0.0, *)
@available(tvOS, unavailable)
public struct OWOWTextField: View {
    // MARK: Init
    
    /// Creates an instance with a placeholder generated from a localized string.
    ///
    /// - Parameters:
    ///     - titleKey: The key for the localized title of `self`, describing its purpose.
    ///     - text: The text to be displayed and edited.
    ///     - hasFocus: A `Binding` to whether the `OWOWTextField` has focus.
    ///     - onCommit: The action to perform when the user performs an action (usually the return key) while the `OWOWTextField` has focus.
    public init(_ titleKey: String? = nil, text: Binding<String>, hasFocus: Binding<Bool>? = nil, onCommit: @escaping () -> Void = {}) {
        self.title = titleKey.map { NSLocalizedString($0, comment: "Text field placeholder") }
        self._text = text
        self.hasFocusBinding = hasFocus
        self.onCommit = onCommit
    }
    
    // MARK: Private State
    
    private var title: String?
    
    /// The text to be displayed and edited.
    @Binding private var text: String
    
    /// The action to perform when the user performs an action (usually the return key) while the `OWOWTextField` has focus.
    private var onCommit: () -> Void
    
    /// The bound value for `hasFocus`.
    private var hasFocusBinding: Binding<Bool>?
    
    /// The `State` that is only used for `hasFocusBinding` when no `hasFocus` binding is used.
    @State private var hasFocusState: Bool = false
    
    /// The text field style that is configured in the environment.
    @Environment(\.owowTextFieldStyle) private var textFieldStyle
    
    /// Whether or not to autofocus the text field.
    private var shouldAutofocus = false
    
    // MARK: View
    
    public var body: some View {
        textFieldStyle
            .makeBody(configuration: self.configuration)
    }
    
    private var configuration: OWOWTextFieldConfiguration {
        OWOWTextFieldConfiguration(
            content: textFieldContent.erasedToAnyView(),
            hasFocus: hasFocusValue
        )
    }
    
    private var textFieldContent: some View {
        _OWOWTextField(
            text: _text,
            title: title,
            onCommit: onCommit,
            hasFocus: hasFocusBinding ?? $hasFocusState,
            shouldAutofocus: shouldAutofocus
        )
        .preference(key: HasFocusPreferenceKey.self, value: hasFocusValue)
    }
    
    /// `true` if the text field currently has the focus.
    private var hasFocusValue: Bool {
        hasFocusBinding?.wrappedValue ?? hasFocusState
    }
    
    /// Make the text field automatically gain focus when it appears.
    public func autofocus() -> Self {
        var copy = self
        copy.shouldAutofocus = true
        return copy
    }
}

/// The `_OWOWTextField` type contains the private implementation of `OWOWTextField`.
@available(iOS 13.0.0, *)
@available(tvOS, unavailable)
fileprivate struct _OWOWTextField: UIViewRepresentable {
    
    // MARK: Configuration
    
    /// Contains configuration for the wrapped `UITextField`.
    @Environment(\.textFieldConfiguration) private var textFieldConfig
    
    /// See the documentation on the `textField(:value:)` view modifier.
    @Environment(\.owowTextFieldDecorationHeight) private var decorationHeight
    
    /// One of the few properties Apple actually exposes in the environment.
    @Environment(\.disableAutocorrection) private var disableAutocorrection
    
    /// One of the few properties Apple actually exposes in the environment.
    @Environment(\.multilineTextAlignment) private var textAlignment
    
    /// The tab index.
    @Environment(\.tabIndex) private var tabIndex
    
    /// The text binding.
    @Binding var text: String
    
    /// The localized title (placeholder) of the text field.
    var title: String?
    
    /// The action to perform when the user performs an action (usually the return key) while the `OWOWTextField` has focus.
    var onCommit: () -> Void
    
    /// Used to keep track of the `isActive` preference key.
    @Binding var hasFocus: Bool
    
    /// Whether or not to autofocus the text field.
    var shouldAutofocus: Bool
    
    // MARK: "Tabbing"
    
    /// Put the tab indexes in their own "namespace" so we can find them on the window.
    private static let tabIndexStartingTag = 8000
    
    /// - returns: The UIView tag to use for the given tabIndex.
    private static func tag(forTabIndex tabIndex: Int) -> Int {
        return tabIndexStartingTag + tabIndex
    }
    
    /// - returns: The tab index for the given view tag, if any.
    private static func tabIndex(forTag tag: Int) -> Int? {
        guard tag >= tabIndexStartingTag else {
            return nil
        }
        
        return tag - tabIndexStartingTag
    }
    
    // MARK: - UIViewRepresentable
    
    class Coordinator: NSObject, UITextFieldDelegate {
        fileprivate var owow: _OWOWTextField
        fileprivate weak var uiField: _UITextField?
        fileprivate var onCommit: () -> Void = {}
        fileprivate var disposables = Set<AnyCancellable>()
        
        init(_ owow: _OWOWTextField) {
            self.owow = owow
            
            super.init()
            
            /// Listen to keyboard frame notifications.
            NotificationCenter.default
                .publisher(for: UIApplication.keyboardWillChangeFrameNotification)
                .replaceOutput(with: ())
                .debounce(for: 0.1, scheduler: DispatchQueue.main)
                .sink { [weak self] _ in
                    guard let self = self, let decorationHeight = owow.decorationHeight else {
                        return
                    }
                    
                    self.uiField?.scrollToField(decorationHeight: decorationHeight)
                }
                .store(in: &disposables)
        }
        
        /// Update the binding.
        @objc func editingChanged(_ textField: UITextField) {
            if let text = textField.text, owow.text != text {
                owow.text = text
            }
        }
        
        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            DispatchQueue.main.async {
                if let height = self.owow.decorationHeight, let textField = textField as? _UITextField {
                    textField.scrollToField(decorationHeight: height)
                }
            }
            
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            onCommit()
            
            if
                let tabIndex = _OWOWTextField.tabIndex(forTag: textField.tag),
                let window = textField.window,
                let nextView = window.viewWithTag(
                    _OWOWTextField.tag(forTabIndex: tabIndex + 1)
                ) {
                nextView.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
            
            return true
        }
    }
    
    func makeUIView(context: UIViewRepresentableContext<_OWOWTextField>) -> _UITextField {
        let textField = _UITextField()
        textField.delegate = context.coordinator
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.editingChanged),
            for: .editingChanged
        )
        
        // Prevent the text field from taking up all vertical space
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        // Prevent the text field from growing horizontally, pushing away other views
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textField
    }
    
    func updateUIView(_ textField: _UITextField, context: UIViewRepresentableContext<_OWOWTextField>) {
        textField.owow = self
        context.coordinator.uiField = textField
        context.coordinator.owow = self
        context.coordinator.onCommit = onCommit
        
        if textField.text != text {
            textField.text = text
        }
        
        textField.autocorrectionType = disableAutocorrection == true ? .no : .default
        textField.textAlignment = NSTextAlignment(textAlignment)
        textField.placeholder = self.title
        
        if let tabIndex = tabIndex {
            textField.tag = Self.tag(forTabIndex: tabIndex)
        }
        
        for config in textFieldConfig {
            config.apply(to: textField)
        }
        
        DispatchQueue.main.async {
            if self.hasFocus != textField.isFirstResponder {
                if self.hasFocus {
                    textField.becomeFirstResponder()
                } else {
                    textField.resignFirstResponder()
                }
            }
        }
    }
    
    func makeCoordinator() -> _OWOWTextField.Coordinator {
        return Coordinator(self)
    }
}

@available(iOS 13.0.0, *)
@available(tvOS, unavailable)
fileprivate final class _UITextField: OWOWUITextField {
    
    var owow: _OWOWTextField?
    
    func scrollToField(decorationHeight: CGFloat) {
        guard self.isFirstResponder else {
            return
        }
        
        guard let scrollView = self.findSuperview(ofType: UIScrollView.self) else {
            return
        }
        
        var expandedBounds = self.bounds
        // Make sure y is center:
        expandedBounds.origin.y += expandedBounds.size.height / 2
        expandedBounds.origin.y = expandedBounds.origin.y - decorationHeight / 2
        expandedBounds.size.height = decorationHeight
        
        let convertedBounds = scrollView.convert(expandedBounds, from: self)
        scrollView.scrollRectToVisible(convertedBounds, animated: true)
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        
        if didResignFirstResponder {
            DispatchQueue.main.async {
                if self.owow?.hasFocus == true {
                    self.owow?.hasFocus = false
                }
            }
        }
        
        return didResignFirstResponder
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        
        if didBecomeFirstResponder {
            self.owow?.hasFocus = true
        }
        
        return didBecomeFirstResponder
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if self.window != nil && owow?.shouldAutofocus == true {
            if #available(iOS 14.0, *) {
                self.becomeFirstResponder()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.becomeFirstResponder()
                }
            }
        }
    }
    
}
