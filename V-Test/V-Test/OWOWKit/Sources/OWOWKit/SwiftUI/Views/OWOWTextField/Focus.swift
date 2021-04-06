import SwiftUI

public struct HasFocusPreferenceKey: PreferenceKey {
    public static var defaultValue = false
    
    public static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}
