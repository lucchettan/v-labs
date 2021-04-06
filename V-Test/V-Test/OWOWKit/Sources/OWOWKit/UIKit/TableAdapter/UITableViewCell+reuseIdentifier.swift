#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UITableViewCell {
    public static func makeUniqueReuseIdentifier() -> String {
        return "\(self)-" + UUID().uuidString
    }
}
#endif
