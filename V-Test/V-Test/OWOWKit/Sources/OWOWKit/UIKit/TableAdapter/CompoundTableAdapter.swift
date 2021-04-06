#if canImport(UIKit) && !os(watchOS)
import UIKit

/// A table adapter that combines multiple single section adapters into one table.
/// It forwards `UITableViewDataSource`, `UITableViewDataSourcePrefetching` and `UITableViewDelegate` calls to the appropriate sub-adapters.
public class CompoundTableAdapter: NSObject, TableAdapter, UITableViewDataSourcePrefetching {
    
    /// The adapters for the table.
    private let adapters: [SingleSectionTableAdapter]
    
    /// The compound table view adapter can forward Scroll View Delegate calls to the given scroll view delegate.
    /// Because zooming is not supported for table views, methods described under "Managing Zooming" in the [UIScrollViewDelegate documentation](https://developer.apple.com/documentation/uikit/uiscrollviewdelegate), are not forwarded.
    /// For methods that should return a value, all delegates are called, but only the return value of the first delegate that implements the method is used.
    public var scrollViewDelegates: [UIScrollViewDelegate] = []
    
    /// Initialise a new `CompoundTableAdapter` consisting of the given `adapters`.
    public init(_ adapters: [SingleSectionTableAdapter]) {
        self.adapters = adapters
        
        super.init() // Bwegh, NSObject.
        
        for (section, adapter) in adapters.enumerated() {
            adapter.managedSection = section
        }
    }
    
    // MARK: - TableAdapter
    
    public func wasAssigned(tableView: UITableView) {
        for adapter in adapters {
            adapter.wasAssigned(tableView: tableView)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return adapters.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adapters[section].tableView(tableView, numberOfRowsInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return adapters[indexPath.section].tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: - UITableViewDataSourcePrefetching
    
    /// Helper to forward a call for a `UITableViewDataSourcePrefetching` method to contained adapters.
    /// - Parameter indexPaths: The index paths.
    /// - Parameter action: The action to call on adapters that support prefetching. The given index paths are already filtered for the adapter.
    private func forwardPrefetching(at indexPaths: [IndexPath], action: (UITableViewDataSourcePrefetching, [IndexPath]) -> Void) {
        for (section, adapter) in adapters.enumerated() {
            guard let adapter = adapter as? UITableViewDataSourcePrefetching else {
                continue
            }
            
            let adapterIndexPaths = indexPaths.filter { $0.section == section }
            
            if adapterIndexPaths.count > 0 {
                action(adapter, adapterIndexPaths)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        forwardPrefetching(at: indexPaths) { adapter, paths in
            adapter.tableView(tableView, prefetchRowsAt: paths)
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        forwardPrefetching(at: indexPaths) { adapter, paths in
            adapter.tableView?(tableView, cancelPrefetchingForRowsAt: paths)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    // MARK: Responding to row selections
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let adapter = adapters[indexPath.section]
        
        /// Just trying to call the method here won't work, because then we cannot see the difference between `nil` returned because the method is not implemented or `nil` returned because the method implementation returns `nil`.
        if adapter.responds(to: #selector(UITableViewDelegate.tableView(_:willSelectRowAt:))) {
            return adapter.tableView?(tableView, willSelectRowAt: indexPath)
        } else {
            return indexPath
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        adapters[indexPath.section].tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        let adapter = adapters[indexPath.section]
        
        /// Just trying to call the method here won't work, because then we cannot see the difference between `nil` returned because the method is not implemented or `nil` returned because the method implementation returns `nil`.
        if adapter.responds(to: #selector(UITableViewDelegate.tableView(_:willDeselectRowAt:))) {
            return adapter.tableView?(tableView, willDeselectRowAt: indexPath)
        } else {
            return indexPath
        }
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        adapters[indexPath.section].tableView?(tableView, didDeselectRowAt: indexPath)
    }
    
    // MARK: Providing custom header and footer views
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return adapters[section].tableView?(tableView, viewForHeaderInSection: section)
    }
    
    // MARK: Providing header, footer and row heights
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return adapters[indexPath.section].tableView?(tableView, heightForRowAt: indexPath) ?? tableView.rowHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return adapters[section].tableView?(tableView, heightForHeaderInSection: section) ?? tableView.sectionHeaderHeight
    }
    
    // MARK: Estimating Heights for the Table's Content
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return adapters[indexPath.section].tableView?(tableView, estimatedHeightForRowAt: indexPath) ?? tableView.estimatedRowHeight
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return adapters[section].tableView?(tableView, estimatedHeightForHeaderInSection: section) ?? tableView.estimatedSectionHeaderHeight
    }
    
    // MARK: - UIScrollViewDelegate
    
    // MARK: Responding to Scrolling and Dragging
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDelegates.forEach { $0.scrollViewDidScroll?(scrollView) }
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewDelegates.forEach { $0.scrollViewWillBeginDragging?(scrollView) }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewDelegates.forEach { $0.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset) }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDelegates.forEach { $0.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate) }
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        // If the delegate doesn’t implement this method, true is assumed – https://developer.apple.com/documentation/uikit/uiscrollviewdelegate
        return scrollViewDelegates.compactMap { $0.scrollViewShouldScrollToTop?(scrollView) }.first ?? true
    }
    
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDelegates.forEach { $0.scrollViewDidScrollToTop?(scrollView) }
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegates.forEach { $0.scrollViewWillBeginDecelerating?(scrollView) }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDelegates.forEach {$0.scrollViewDidEndDecelerating?(scrollView) }
    }
    
    // MARK: Responding to Scrolling Animations
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDelegates.forEach { $0.scrollViewDidEndScrollingAnimation?(scrollView) }
    }
    
    // MARK: Responding to Inset Changes
    
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollViewDelegates.forEach { $0.scrollViewDidChangeAdjustedContentInset?(scrollView) }
    }
    
}
#endif
