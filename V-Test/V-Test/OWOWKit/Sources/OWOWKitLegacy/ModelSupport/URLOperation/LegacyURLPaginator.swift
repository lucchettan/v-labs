import Foundation

#if canImport(UIKit) && !os(watchOS)
import UIKit // May seem weird, but this is so we can respond to memory warning notifications.
#endif

/// A class that paginates the contents of a URL that supports pagination, using URLOperation.
public final class URLPaginator<Request: Requestable, Page: PaginatedResponse>: Paginator {
    
    /// One element on a page.
    public typealias Element = Page.Element
    
    /// The `URLOperation` type to be used with this paginator.
    typealias Operation = URLOperation<Request, Page>
    
    // MARK: Properties
    
    /// The operation queue to execute requests on.
    private let queue = OperationQueue()
    
    /// The base URL to use.
    private let baseURL: String
    
    /// The URL to request.
    private let url: String
    
    /// The request.
    private let request: Request
    
    /// The URL session.
    private let session: URLSession
    
    /// Query string parameters.
    public var parameters: [String: String?] {
        didSet {
            reload()
        }
    }
    
    /// Request criteria.
    public var criteria: CriteriaSet {
        didSet {
            reload()
        }
    }
    
    /// Operations managed by the paginator.
    /// The key is the page number of the request.
    private var operations = [Int: Operation]()
    
    /// The amount of items to fetch per page.
    public let numberOfItemsPerPage: Int
    
    /// Manages subscribers for the `onCount` event.
    private var onCountManager = CompletionManager<Int?>(oneTime: false)
    
    // MARK: Init
    
    /// Initialises a new Paginator with the given parameters.
    public init(
        url: String,
        request: Request,
        parameters: [String: String?] = [:],
        session: URLSession = URLSession.shared,
        baseURL: String = OWOWKitConfiguration.baseURL,
        numberOfItemsPerPage: Int = 15,
        criteria: CriteriaSet = []
    ) {
        self.baseURL = baseURL
        self.url = url
        self.request = request
        self.session = session
        self.parameters = parameters
        self.numberOfItemsPerPage = numberOfItemsPerPage
        self.criteria = criteria
        
        // Fetch the first item
        _ = self.get(index: 0)
        
        #if canImport(UIKit) && !os(watchOS)
        // Observe memory warnings
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        #endif
    }
    
    // MARK: Public API
    
    /// Gets the item at the specified index. This can have one of three effects:
    ///
    /// - The page containing the item is already fetched: the item is received from the cache
    /// - The page containing the item is already in the process of being fetched: the returned future will use the results from the existing request
    /// - The page containing the item is not yet requested: a network request is fired
    ///
    /// - returns: A `Future` that will resolve to the item.
    public func get(index: Int) -> Future<Element> {
        let page = index / numberOfItemsPerPage + 1
        let relativeIndex = index % numberOfItemsPerPage
        let promise = Promise<Element>()
        let operation = fetch(page: page)
        
        _ = operation.onComplete { result in
            let finalResult = self.finalResult(
                forRelativeItemIndex: relativeIndex,
                withPageResult: result
            )
            
            promise.fulfill(finalResult)
        }
        
        return promise.futureResult
    }
    
    public func get(page: Int) -> Future<[Page.Element]> {
        let promise = Promise<[Page.Element]>()
        
        _ = fetch(page: page).onComplete { result in
            promise.fulfill(result.map { $0.body.data })
        }
        
        return promise.futureResult
    }
    
    public func reload() {
        print("[Paginator] Reloading")
        
        self.reset()
        _ = get(index: 0)
    }
    
    /// Registers a handler for receiving count events.
    public func onCount(_ handler: @escaping (Int?) -> Void) -> (() -> Void) {
        return onCountManager.add(handler: handler)
    }
    
    /// Prefetches the pages for the given `indices`.
    public func prefetch(indices: [Int]) {
        let pages = Set(indices.map { $0 / numberOfItemsPerPage + 1 })
        
        for page in pages {
            _ = self.fetch(page: page, forPrefetch: true)
        }
    }
    
    // MARK: Internal logic
    
    private func finalResult(forRelativeItemIndex index: Int, withPageResult result: Swift.Result<Response<Page>, Error>) -> Swift.Result<Element, Error> {
        switch result {
        case .success(let response):
            guard response.body.data.count > index else {
                return .failure(PaginationError.indexOutOfBounds)
            }
            
            return .success(response.body.data[index])
        case .failure(let error):
            return .failure(error)
        }
    }
    
    /// Cancels all operations and removes them.
    private func reset() {
        operations.removeAll()
        queue.cancelAllOperations()
        onCountManager.publish(element: nil)
    }
    
    /// Fetches the given page.
    private func fetch(page: Int, forPrefetch: Bool = false) -> Operation {
        if let page = operations[page] {
            return page
        }
        
        if forPrefetch {
            print("[Paginator] Prefetching page \(page)")
        }
        
        var parameters = self.parameters
        parameters["page"] = String(page)
        parameters["per_page"] = String(numberOfItemsPerPage)
        
        let operation = Operation(
            url: self.url,
            request: self.request,
            parameters: parameters,
            session: self.session,
            baseURL: self.baseURL,
            criteria: self.criteria
        )
        
        self.operations[page] = operation
        self.queue.addOperation(operation)
        
        _ = operation.onComplete { response in
            switch response {
            case .success(let response):
                self.onCountManager.publish(element: response.body.total)
            case .failure(let error):
                print("[Paginator] failure: \(error)")
                self.operations[page] = nil
            }
        }
        
        return operation
    }
    
    @objc func didReceiveMemoryWarning() {
        print("[Paginator] Cleaning up cache because of memory warning")
        self.operations.removeAll() // Don't cancel running operations, clients may be waiting for results
    }
}

extension URLPaginator where Request == Get {
    public convenience init(
        url: String,
        parameters: [String: String?] = [:],
        session: URLSession = URLSession.shared,
        baseURL: String = OWOWKitConfiguration.baseURL,
        numberOfItemsPerPage: Int = 15,
        criteria: CriteriaSet = []
    ) {
        self.init(
            url: url,
            request: .init(),
            parameters: parameters,
            session: session,
            baseURL: baseURL,
            numberOfItemsPerPage: numberOfItemsPerPage,
            criteria: criteria
        )
    }
}
