import Foundation
import Combine

public enum PaginationError: Error {
    case indexOutOfBounds
}

/// A class that paginates the contents of a URL that supports pagination, using URLOperation.
@available(iOS 13, *)
public final class URLPaginator<Request: Requestable, Page: PaginatedResponse>: Paginator {
    
    /// One element on a page.
    public typealias Element = Page.Element
    
    // MARK: Properties
    
    /// The URL to request.
    private let url: String
    
    /// The request.
    private let request: Request
    
    /// The URL session to use.
    private let session: URLSession
    
    /// Query string parameters.
    public var parameters: [String: String?] {
        didSet {
            reload()
        }
    }
    
    public var criteria: CriteriaSet {
        didSet {
            reload()
        }
    }
    
    /// The amount of items to fetch per page.
    public let numberOfItemsPerPage: Int
    
    /// Publishers managed by the paginator.
    /// The key is the page number of the request.
    private var publishers = [Int: AnyPublisher<Response<Page>, Error>]()
    
    /// 🗑 Combine cancellables.
    private var prefetchCancellables = Set<AnyCancellable>()
    
    public var count = CurrentValueSubject<Int?, Never>(nil)
    
    // MARK: Init
    
    public init(
        url: String,
        request: Request,
        parameters: [String: String?] = [:],
        session: URLSession,
        numberOfItemsPerPage: Int = 15,
        criteria: CriteriaSet = []
    ) {
        self.url = url
        self.request = request
        self.parameters = parameters
        self.session = session
        self.numberOfItemsPerPage = numberOfItemsPerPage
        self.criteria = criteria
    }
    
    // MARK: Paginator
    
    public func get(index: Int) -> AnyPublisher<Page.Element, Error> {
        let page = index / numberOfItemsPerPage + 1
        let relativeIndex = index % numberOfItemsPerPage
        
        return fetch(page: page)
            .tryMap { response in
                guard response.body.data.count > relativeIndex else {
                    throw PaginationError.indexOutOfBounds
                }
                
                return response.body.data[relativeIndex]
            }
            .eraseToAnyPublisher()
    }
    
    public func prefetch(indices: [Int]) {
        let pages = Set(indices.map { $0 / numberOfItemsPerPage + 1 })
        
        for page in pages {
            self.fetch(page: page, forPrefetch: true)
                .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                .store(in: &prefetchCancellables)
        }
    }
    
    public func reload() {
        print("[Paginator] Reloading")
        
        publishers.removeAll()
        prefetchCancellables.removeAll()
    }
    
    private func fetch(page: Int, forPrefetch: Bool = false) -> AnyPublisher<Response<Page>, Error> {
        if let publisher = publishers[page] {
            return publisher
        }
        
        if forPrefetch {
            print("[Paginator] Prefetching page \(page)")
        }
        
        var parameters = self.parameters
        parameters["page"] = String(page)
        parameters[OWOWKitConfiguration.perPageParameterName] = String(numberOfItemsPerPage)
        
        do {
            let request = try URLRequest(
                request: self.request,
                url: self.url,
                parameters: parameters,
                criteria: criteria
            )
            
            let publisher = session
                .responsePublisher(for: request, responseBody: Page.self)
                .handleEvents(receiveOutput: { response in
                    if self.count.value != response.body.total {
                        self.count.value = response.body.total
                    }
                })
                .shareReplay(1)
                .eraseToAnyPublisher()
            
            publishers[page] = publisher
            return publisher
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
    
    public func forEach(_ body: @escaping (Page.Element) throws -> Void) -> AnyPublisher<Void, Error> {
        return Future { fulfill in
            var cancellables = Set<AnyCancellable>()
            var currentIndex = 0
            
            func next() {
                self.get(index: currentIndex)
                    .receive(on: DispatchQueue.main)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            if case PaginationError.indexOutOfBounds = error {
                                print(currentIndex)
                                fulfill(.success(()))
                            } else {
                                fulfill(.failure(error)) // Cancel because of an errro
                            }
                        }
                    } receiveValue: { element in
                        do {
                            try body(element)
                            currentIndex += 1
                            next()
                        } catch {
                            fulfill(.failure(error))
                        }
                    }
                    .store(in: &cancellables)
            }
            
            next()
        }
        .eraseToAnyPublisher()
    }
}

@available(iOS 13, *)
extension URLPaginator where Request == Get {
    public convenience init(
        url: String,
        parameters: [String: String?] = [:],
        session: URLSession,
        numberOfItemsPerPage: Int = 15,
        criteria: CriteriaSet = []
    ) {
        self.init(
            url: url,
            request: Get(),
            parameters: parameters,
            session: session,
            numberOfItemsPerPage: numberOfItemsPerPage,
            criteria: criteria
        )
    }
}
