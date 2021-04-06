#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UITableView {
    /// The adapter that is in use on the table view. When set, this overwrites the `dataSource`, `delegate`, and `prefetchDataSource` properties.
    public var adapter: TableAdapter? {
        get {
            return self.dataSource as? TableAdapter
        }
        set {
            self.dataSource = newValue
            self.delegate = newValue
            self.prefetchDataSource = newValue as? UITableViewDataSourcePrefetching
            
            newValue?.wasAssigned(tableView: self)
        }
    }
}
#endif
