import Foundation

/// An instance of `SearchManager` can be used to submit search queries. The queries are debonuced.
public class SearchManager<C, T> where C: SearchCriteria {
    /// The target instance that criteria are written to.
    private var target: T

    /// The key path on the target instance that criteria are written to.
    private let targetKeyPath: WritableKeyPath<T, CriteriaSet>
    
    /// The current query to submit.
    private var currentQuery: String = ""
    
    /// The last query that was submitted.
    public private(set) var lastSubmittedQuery: String = ""
    
    /// Initialises a new `SearchManager` with the given criteria.
    public init(criteriaType: C.Type = C.self, target: T, keyPath: WritableKeyPath<T, CriteriaSet>) {
        self.target = target
        self.targetKeyPath = keyPath
    }
    
    /// Submit a search query.
    public func submit(_ query: String) {
        self.currentQuery = query
        
        // Don't submit the same query twice in a row.
        if currentQuery != lastSubmittedQuery {
            self.writeQuery()
        } else {
            self.writeQuery.cancel()
        }
    }
    
    /// A debounced function that writes the query to the target.
    private lazy var writeQuery = Debounced(timeInterval: 0.3) { [weak self] in
        guard let `self` = self else { return }
        
        let criteria = C(searchString: self.currentQuery)
        self.target[keyPath: self.targetKeyPath].add(criteria)
        self.lastSubmittedQuery = self.currentQuery
    }
}
