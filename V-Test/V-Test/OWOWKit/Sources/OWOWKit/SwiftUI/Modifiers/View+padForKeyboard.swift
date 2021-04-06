import SwiftUI

@available(iOS 13, *)
@available(tvOS, unavailable)
@usableFromInline
struct PadForKeyboard: ViewModifier {
    var paddingWithoutKeyboard: CGFloat
    var extraPaddingWithKeyboard: CGFloat
    var adjustingSafeArea: Bool
    var activeWhenKeyboardSafeAreaAvailable: Bool
    
    @usableFromInline
    init(
        paddingWithoutKeyboard: CGFloat,
        extraPaddingWithKeyboard: CGFloat,
        adjustingSafeArea: Bool,
        activeWhenKeyboardSafeAreaAvailable: Bool
    ) {
        self.paddingWithoutKeyboard = paddingWithoutKeyboard
        self.extraPaddingWithKeyboard = extraPaddingWithKeyboard
        self.adjustingSafeArea = adjustingSafeArea
        self.activeWhenKeyboardSafeAreaAvailable = activeWhenKeyboardSafeAreaAvailable
    }
    
    @usableFromInline
    func body(content: Content) -> some View {
        if #available(iOS 14, *), activeWhenKeyboardSafeAreaAvailable == false, paddingWithoutKeyboard == 0, extraPaddingWithKeyboard == 0 {
            return content
                .padding(.bottom, paddingWithoutKeyboard)
                .erasedToAnyView()
        } else {
            return KeyboardHeightReader { height -> AnyView in
                if #available(iOS 14, *), activeWhenKeyboardSafeAreaAvailable == false {
                    return content
                        .padding(.bottom, height > 0 ? extraPaddingWithKeyboard : paddingWithoutKeyboard)
                        .erasedToAnyView()
                } else {
                    return content
                        .padding(
                            .bottom,
                            height > 0 ? height + self.extraPaddingWithKeyboard : self.paddingWithoutKeyboard
                        )
                        .if(self.adjustingSafeArea) { $0.edgesIgnoringSafeArea(height > 0 ? .bottom : []) }
                        .erasedToAnyView()
                }
            }
            .erasedToAnyView()
        }
    }
}

@available(iOS 13, *)
@available(tvOS, unavailable)
@usableFromInline
struct AutoPadForKeyboard: ViewModifier {
    @State var initialBottomPadding: CGFloat = 0
    var activeWhenKeyboardSafeAreaAvailable: Bool
    
    @usableFromInline
    init(activeWhenKeyboardSafeAreaAvailable: Bool) {
        self.activeWhenKeyboardSafeAreaAvailable = activeWhenKeyboardSafeAreaAvailable
    }
    
    @usableFromInline
    func body(content: Content) -> some View {
        if #available(iOS 14, *), activeWhenKeyboardSafeAreaAvailable == false {
            return content
                .erasedToAnyView()
        } else {
            return KeyboardHeightReader { height in
                content
                    .overlay(GeometryReader(content: { self.store(geometry: $0, keyboardHeight: height) }))
                    .padding(
                        .bottom,
                        height > self.initialBottomPadding ? height - self.initialBottomPadding : 0
                    )
                    .edgesIgnoringSafeArea(height > self.initialBottomPadding ? .bottom : [])
            }
            .erasedToAnyView()
        }
    }
    
    @usableFromInline
    func store(geometry: GeometryProxy, keyboardHeight: CGFloat) -> AnyView {
        let calculatedPadding = UIScreen.main.bounds.height - geometry.frame(in: .global).maxY
        
        if keyboardHeight == 0, calculatedPadding != initialBottomPadding {
            DispatchQueue.main.async {
                self.initialBottomPadding = calculatedPadding
            }
        }
        
        return EmptyView().erasedToAnyView()
    }
}

@available(iOS, introduced: 13, deprecated: 14, message: "iOS 14 provides native keyboard handling using the safe area")
@available(tvOS, unavailable)
extension View {
    /// Automatically adds and adjusts bottom padding to the view when the keyboard appears.
    /// - Parameters:
    ///   - paddingWithoutKeyboard: Extra padding to apply when the keyboard is not visible.
    ///   - extraPaddingWithKeyboard: Extra padding to apply when the keyboard is visible.
    ///   - adjustingSafeArea: Normally, the modifier automatically ignores the bottom safe area when the keyboard is visible. If this adjusting the safe area is unwanted, this can be set to `false`.
    ///   - activeWhenKeyboardSafeAreaAvailable: When set to `true`, the modifier will be active even on iOS 14 and later. Even with this set to `false`, `paddingWithoutKeyboard` and `extraPaddingWithKeyboard` are still respected.
    /// - Returns: A view that adjusts it's padding for the keyboard.
    @inlinable
    public func padForKeyboard(paddingWithoutKeyboard: CGFloat = 0, extraPaddingWithKeyboard: CGFloat = 0, adjustingSafeArea: Bool = true, activeWhenKeyboardSafeAreaAvailable: Bool = false) -> some View {
        return self.modifier(PadForKeyboard(paddingWithoutKeyboard: paddingWithoutKeyboard, extraPaddingWithKeyboard: extraPaddingWithKeyboard, adjustingSafeArea: adjustingSafeArea, activeWhenKeyboardSafeAreaAvailable: activeWhenKeyboardSafeAreaAvailable))
    }
    
    /// Similar to `padForKeyboard`, automatically adds and adjusts bottom padding to the view when the keyboard appears.
    /// The difference with the normal `padForKeyboard`, is that this version uses a `GeometryReader` to determine the initial bottom padding of the view,
    /// which is then subtracted from the keyboard padding.
    /// - Parameter activeWhenKeyboardSafeAreaAvailable: When set to `true`, the modifier will be active even on iOS 14 and later.
    /// - Returns: A view that adjusts it's padding for the keyboard.
    @inlinable
    public func autoPadForKeyboard(activeWhenKeyboardSafeAreaAvailable: Bool = false) -> some View {
        return self.modifier(AutoPadForKeyboard(activeWhenKeyboardSafeAreaAvailable: activeWhenKeyboardSafeAreaAvailable))
    }
}
