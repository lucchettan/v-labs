#if canImport(UIKit) && !os(watchOS)
import UIKit

/// A table view adapter that adds a section header to a table view.
public class SectionHeaderTableViewAdapter<Header: UIView, RowAdapter: NSObject & SingleSectionTableAdapter>: NSObject, SingleSectionTableAdapter, UITableViewDataSourcePrefetching {
    public var managedSection: Int {
        get {
            return rowAdapter.managedSection
        }
        set {
            rowAdapter.managedSection = newValue
        }
    }
    
    public let rowAdapter: RowAdapter
    public let header: Header
    
    public let height: CGFloat
    public let estimatedHeight: CGFloat
    
    public init(header: Header, estimatedHeight: CGFloat, height: CGFloat = UITableView.automaticDimension, rowAdapter: RowAdapter) {
        self.header = header
        self.height = height
        self.estimatedHeight = estimatedHeight
        self.rowAdapter = rowAdapter
    }
    
    // Table view header
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return estimatedHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return height
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }
    
    // MARK: Objective C Selector Forwarding
    
    public override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector) || rowAdapter.responds(to: aSelector)
    }
    
    public override class func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector) || RowAdapter.responds(to: aSelector)
    }
    
    public override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if super.responds(to: aSelector) {
            return self
        } else {
            return rowAdapter
        }
    }
    
    public override class func forwardingTarget(for aSelector: Selector!) -> Any? {
        if super.responds(to: aSelector) {
            return self
        } else {
            return RowAdapter.self
        }
    }
    
    // MARK: Required methods
    
    public func wasAssigned(tableView: UITableView) {
        rowAdapter.wasAssigned(tableView: tableView)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowAdapter.tableView(tableView, numberOfRowsInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return rowAdapter.tableView(tableView, cellForRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let rowAdapter = self.rowAdapter as? UITableViewDataSourcePrefetching else {
            return
        }
        
        rowAdapter.tableView(tableView, prefetchRowsAt: indexPaths)
    }
    
}
#endif
