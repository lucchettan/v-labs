import SwiftUI
import UIKit

@available(iOS 13, *)
extension NSTextAlignment {
    public init(_ textAlignment: TextAlignment) {
        switch textAlignment {
        case .leading:
            self = .left
        case .center:
            self = .center
        case .trailing:
            self = .right
        }
    }
}
