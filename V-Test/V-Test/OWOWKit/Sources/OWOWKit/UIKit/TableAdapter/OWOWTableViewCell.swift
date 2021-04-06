#if canImport(UIKit) && !os(watchOS)
import UIKit

/// A table view cell that has a reuse identifier and can register itself on a table view.
public protocol OWOWTableViewCell {
    /// Orders the table view cell type to register itself on the table view. It must use the given `reuseIdentifier`.
    static func register(on tableView: UITableView, with reuseIdentifier: String)
    
    /// The value a table view adapter should return for the estimated height of a cell.
    static var estimatedHeight: CGFloat { get }
    
    /// The value a table view adapter should return for the height of a cell.
    static var height: CGFloat { get }
}
#endif
