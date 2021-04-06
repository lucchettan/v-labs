#if canImport(UIKit) && !os(watchOS)
import UIKit

/// A table adapter is a type that can serve as the data source for (a part of) a table view.
/// Adapters are usually responsible for managing the rows in one section of a table view, except for compound table adapters, which combine multiple table views.
///
/// Table adapters are used by assigning them to the `adapter` property on a table view.
public protocol TableAdapter: UITableViewDataSource, UITableViewDelegate {
    /// Indicates that the adapter was assigned to the given `tableView`.
    /// It is not valid for an adapter to be used in multiple table views at the same time.
    func wasAssigned(tableView: UITableView)
}

/// A table adapter that manages the rows in a single section.
public protocol SingleSectionTableAdapter: TableAdapter {
    /// The section that is managed by the table adapter.
    /// A compound table adapter will set this.
    ///
    /// Changing the value of `managedSection` after the table adapter started handling `UITableViewDataSource` requests is usually not safe.
    var managedSection: Int { get set }
}
#endif
