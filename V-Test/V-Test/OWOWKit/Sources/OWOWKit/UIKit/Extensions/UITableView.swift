#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UITableView {
    public func scrollToTop(animated: Bool) {
        self.setContentOffset(CGPoint(x: -self.contentInset.left, y: -self.contentInset.top), animated: animated)
    }
    
    public func scrollToBottom(animated: Bool) {
        guard numberOfSections > 0 else {
            return
        }
        
        let lastSection = numberOfSections-1
        let lastSectionRows = self.numberOfRows(inSection: lastSection)
        
        scrollToRow(at: IndexPath(row: lastSectionRows-1, section: lastSection), at: .bottom, animated: animated)
    }
    
    public func reload(section: Int, withRowAnimation animation: UITableView.RowAnimation) {
        let indexSet = IndexSet(integer: section)
        self.reloadSections(indexSet, with: animation)
    }
}
#endif
