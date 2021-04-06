#if canImport(UIKit) && !os(watchOS)
import UIKit
import OWOWKit

public final class PaginatorTableAdapter<P, C>: NSObject, SingleSectionTableAdapter, UITableViewDataSourcePrefetching where P: Paginator, C: UITableViewCell & AsyncTableViewCell, P.Element == Bindable<C.Element> {
    
    /// The mode the table adapter uses to handle updates to the row count.
    public enum RowCountUpdateMode {
        case insertAndDelete
        case reloadSection
        case reloadEntireTable
    }
    
    /// The table view.
    private weak var tableView: UITableView?
    
    /// The section managed by the table adapter.
    public var managedSection: Int = 0
    
    /// The paginator instance that is adapter for the table view.
    private let paginator: P
    
    /// A closure that is called with the new row count before the table view is updated to acommodate a new number of rows.
    /// It will be called on the main thread.
    ///
    /// - Parameter 1: The old row count
    /// - Parameter 2: The new row count
    public var beforeRowCountUpdate: ((Int?, Int?) -> Void)?
    
    /// A closure that is called with the new row count after the table view is updated to acommodate a new number of rows.
    /// It will be called on the main thread.
    ///
    /// - Parameter 1: The old row count
    /// - Parameter 2: The new row count
    public var afterRowCountUpdate: ((Int?, Int?) -> Void)?
    
    /// A closure that is executed when a row is selected.
    public var onRowSelection: ((P.Element) -> Void)?
    
    /// Contains the actual row count value. Abstracted so we can update the actual count in the setter of `rowCount`.
    private var _rowCount: Int?
    
    /// The mode the table adapter uses to handle updates to the row count.
    public var rowCountUpdateMode: RowCountUpdateMode = .insertAndDelete
    
    /// The animation that is used when handling row count updates.
    ///
    /// - note: This has no effect when the `rowCountUpdateMode` is set to `reloadEntireTable`
    public var rowCountUpdateAnimation: UITableView.RowAnimation = .none
    
    /// Can be used for performance reasons. When set, the adapter will never display more than `rowLimit` rows.
    public var rowLimit: Int? = nil
    
    /// The row count.
    /// A rowCount of `nil` means that the row count is currently unknown, because the paginator is loading.
    public private(set) var rowCount: Int? {
        get {
            return _rowCount
        }
        set {
            var clampedNewValue: Int?
            if let newValue = newValue, let rowLimit = rowLimit, newValue > rowLimit {
                clampedNewValue = rowLimit
            } else {
                clampedNewValue = newValue
            }
            
            assert(Thread.isMainThread)
            
            let oldValue = self._rowCount
            let oldValueOrZero = oldValue ?? 0
            let newValueOrZero = clampedNewValue ?? 0
            
            self.beforeRowCountUpdate?(oldValue, clampedNewValue)
            defer {
                self.afterRowCountUpdate?(oldValue, clampedNewValue)
            }
            
            // While reloading the paginator will set a row count of 0, so this is safe.
            guard oldValueOrZero != newValueOrZero, let tableView = self.tableView else {
                _rowCount = clampedNewValue
                return
            }
            
            // Disable animations if no animation was requested
            let animationsWereEnabled: Bool? // nil if we didn't adjust animations
            if rowCountUpdateAnimation == .none {
                animationsWereEnabled = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
            } else {
                animationsWereEnabled = nil
            }
            
            defer {
                if let animationsWereEnabled = animationsWereEnabled {
                    UIView.setAnimationsEnabled(animationsWereEnabled)
                }
            }
            
            switch rowCountUpdateMode {
            case .insertAndDelete:
                let prependedRows = prependedAdapter?.tableView(tableView, numberOfRowsInSection: self.managedSection) ?? 0
                
                tableView.performBatchUpdates({
                    if oldValueOrZero < newValueOrZero {
                        // More results.
                        let indexPathsToAdd = (oldValueOrZero..<newValueOrZero).map { IndexPath(row: prependedRows + $0, section: self.managedSection) }
                        tableView.insertRows(at: indexPathsToAdd, with: self.rowCountUpdateAnimation)
                    } else if oldValueOrZero > newValueOrZero {
                        // Less results.
                        let indexPathsToRemove = (newValueOrZero..<oldValueOrZero).map { IndexPath(row: prependedRows + $0, section: self.managedSection) }
                        tableView.deleteRows(at: indexPathsToRemove, with: self.rowCountUpdateAnimation)
                    }
                    
                    _rowCount = clampedNewValue
                }, completion: nil)
                
                tableView.indexPathsForVisibleRows?
                    .filter { $0.section == self.managedSection }
                    .forEach { indexPath in
                        let (adapter, shiftedIndexPath) = self.affixedAdapterAndAdjustedIndexPath(forRowAtIndexPath: indexPath, tableView: tableView)
                        
                        guard adapter == nil, let cell = tableView.cellForRow(at: indexPath) as? C else {
                            return
                        }
                        
                        let element = paginator.get(index: shiftedIndexPath.row)
                        cell.load(element: element)
                }
            case .reloadSection:
                _rowCount = clampedNewValue
                tableView.reload(section: self.managedSection, withRowAnimation: self.rowCountUpdateAnimation)
            case .reloadEntireTable:
                _rowCount = clampedNewValue
                tableView.reloadData()
            }
        }
    }
    
    /// Use a unique reuse identifier - multiple adapters might use the same table view cell classes through a `CompoundTableAdapter` and we don't want their cells to mix up.
    let reuseIdentifier = "\(C.self)-" + UUID().uuidString
    
    /// A single section adapter, of which the rows are prepended before the first paginated rows.
    public let prependedAdapter: SingleSectionTableAdapter?
    
    /// A single section adapter, of which the rows are appended after the last paginated rows.
    public let appendedAdapter: SingleSectionTableAdapter?
    
    /// Initialises a new `PaginatorTableAdapter` with the given table view cell.
    /// The cell is registered on the table view automatically.
    public init(
        paginator: P,
        cellType: C.Type,
        prependedAdapter: SingleSectionTableAdapter? = nil,
        appendedAdapter: SingleSectionTableAdapter? = nil
    ) {
        self.paginator = paginator
        self.prependedAdapter = prependedAdapter
        self.appendedAdapter = appendedAdapter
        
        super.init()
        
        _ = paginator.onCount { [weak self] count in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                self.rowCount = count
            }
        }
    }
    
    public func wasAssigned(tableView: UITableView) {
        self.tableView = tableView
        C.register(on: tableView, with: self.reuseIdentifier)
        
        for adapter in [prependedAdapter, appendedAdapter] {
            adapter?.wasAssigned(tableView: tableView)
        }
    }
    
    /// A helper method that helps in supporting the prepended and appended table adapters.
    /// Given an index path, it will return the section adapter that is responsible for handling the given row (or `nil` when the given row is part of the paginated data), and the index path shifted for the namespace of the returned table adapter or `self`.
    private func affixedAdapterAndAdjustedIndexPath(forRowAtIndexPath indexPath: IndexPath, tableView: UITableView) -> (SingleSectionTableAdapter?, IndexPath) {
        let prependedEndIndex = prependedAdapter?.tableView(tableView, numberOfRowsInSection: indexPath.section) ?? 0
        let paginatedEndIndex = prependedEndIndex + (rowCount ?? 0)
        let appendedEndIndex = paginatedEndIndex + (appendedAdapter?.tableView(tableView, numberOfRowsInSection: indexPath.section) ?? 0)
        
        if 0..<prependedEndIndex ~= indexPath.row, let prependedAdapter = prependedAdapter {
            return (prependedAdapter, indexPath)
        } else if paginatedEndIndex..<appendedEndIndex ~= indexPath.row, let appendedAdapter = appendedAdapter {
            let shiftedIndexPath = IndexPath(
                row: indexPath.row - paginatedEndIndex,
                section: indexPath.section
            )
            
            return (appendedAdapter, shiftedIndexPath)
        } else {
            let shiftedIndexPath = IndexPath(
                row: indexPath.row - prependedEndIndex,
                section: indexPath.section
            )
            
            return (nil, shiftedIndexPath)
        }
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let prependedAmount = prependedAdapter?.tableView(tableView, numberOfRowsInSection: self.managedSection) ?? 0
        
        paginator.prefetch(
            indices: indexPaths.map { $0.row - prependedAmount }
        )
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let prependedAmount = prependedAdapter?.tableView(tableView, numberOfRowsInSection: section) ?? 0
        let paginatedAmount = rowCount ?? 0
        let appendedAmount = appendedAdapter?.tableView(tableView, numberOfRowsInSection: section) ?? 0
        
        return prependedAmount + paginatedAmount + appendedAmount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (adapter, shiftedIndexPath) = self.affixedAdapterAndAdjustedIndexPath(forRowAtIndexPath: indexPath, tableView: tableView)
        
        if let adapter = adapter {
            return adapter.tableView(tableView, cellForRowAt: shiftedIndexPath)
        }
            
        let element = paginator.get(index: shiftedIndexPath.row)
        
        // The cell itself is responsible for registering the correct class, so this cast should not fail.
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! C
        cell.load(element: element)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let (adapter, shiftedIndexPath) = self.affixedAdapterAndAdjustedIndexPath(forRowAtIndexPath: indexPath, tableView: tableView)
        
        if let adapter = adapter {
            return adapter.tableView?(tableView, estimatedHeightForRowAt: shiftedIndexPath) ?? tableView.estimatedRowHeight
        } else {
            return C.estimatedHeight
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let (adapter, shiftedIndexPath) = self.affixedAdapterAndAdjustedIndexPath(forRowAtIndexPath: indexPath, tableView: tableView)
        
        if let adapter = adapter {
            return adapter.tableView?(tableView, heightForRowAt: shiftedIndexPath) ?? tableView.rowHeight
        } else {
            return C.height
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (adapter, shiftedIndexPath) = self.affixedAdapterAndAdjustedIndexPath(forRowAtIndexPath: indexPath, tableView: tableView)
        
        if let adapter = adapter {
            adapter.tableView?(tableView, didSelectRowAt: shiftedIndexPath)
        } else {
            guard let cell = tableView.cellForRow(at: indexPath) as? C else {
                return
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            guard let element = cell.currentlyVisibleElement else {
                return
            }
            
            self.onRowSelection?(element)
        }
    }
}
#endif
