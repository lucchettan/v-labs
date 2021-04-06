/// A type of criteria that can be used to filter results by a search string.
public protocol SearchCriteria: Criteria {
    /// The search string.
    var searchString: String { get set }
    
    /// Initialise a new SearchCriteria with the given search string.
    init(searchString: String)
}
