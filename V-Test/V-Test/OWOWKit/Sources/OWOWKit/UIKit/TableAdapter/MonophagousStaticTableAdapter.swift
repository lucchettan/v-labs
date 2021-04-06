#if canImport(UIKit) && !os(watchOS)
import UIKit

/// A table adapter for a static number of rows of a single row type.
public final class MonophagousStaticTableAdapter<C: UITableViewCell & OWOWTableViewCell>: NSObject, SingleSectionTableAdapter {
    
    /// A type that configures cells.
    public typealias CellConfigurator = (C, UITableView, IndexPath) -> Void
    
    /// The section managed by the table adapter.
    public var managedSection: Int = 0
    
    /// The number of rows.
    public let numberOfRows: Int
    
    /// The cell provider.
    private let cellConfigurator: CellConfigurator
    
    /// The reuse identifier.
    private let reuseIdentifier = C.makeUniqueReuseIdentifier()
    
    /// Initialise a new table view adapter with the given number of rows and cell configurator.
    public init(numberOfRows: Int = 1, cellConfigurator: @escaping CellConfigurator = { _, _, _ in }) {
        self.numberOfRows = numberOfRows
        self.cellConfigurator = cellConfigurator
    }
    
    public func wasAssigned(tableView: UITableView) {
        C.register(on: tableView, with: reuseIdentifier)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // The cell itself is responsible for registering the correct class, so this cast should not fail.
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! C
        cellConfigurator(cell, tableView, indexPath)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return C.estimatedHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return C.height
    }
    
}
#endif
