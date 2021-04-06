import OWOWKit

#if canImport(UIKit) && !os(watchOS)
public protocol AsyncTableViewCell: OWOWTableViewCell {
    /// The element that the cell can load.
    associatedtype Element
    
    /// Loads the given element into the cell.
    func load(element: Future<Bindable<Element>>)
    
    /// The currently visible element in the cell.
    /// In implementations of `load(element:)`, cells must set this to `nil` if the cell is loading or in an error state.
    /// After the loading is complete, cells should set this to the element they are currently displaying.
    var currentlyVisibleElement: Bindable<Element>? { get }
}
#endif
