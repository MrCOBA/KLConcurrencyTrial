import OSLog

// MARK: - Types

struct Product {
    
    let identifier: String
    let devices: Int
    
}

enum ProductsProviderError: Error {
    case networkError
}

// MARK: - Protocols

protocol ProductsRequester: AnyObject {
    
    func requestProducts() async throws -> [(String, Int)]
}

protocol ProductsProvider: AnyObject {
    
    typealias Error = ProductsProviderError
    
    func getProducts() async throws -> [Product]
    
}

// MARK: - ProductsProvider

final class ProductsProviderImpl: ProductsProvider {
    
    // MARK: - Private Properties
    
    private let requester: ProductsRequester
    private var cachedProducts = [Product]()
    private var currentTask: Task<[Product], Error>?
    
    private let logger = Logger()
    
    // MARK: - Init
    
    init(requester: ProductsRequester) {
        self.requester = requester
    }
    
    // MARK: - Internal Methods
    
    func getProducts() async throws -> [Product] {
        if currentTask != nil {
            logger.debug("Products already requested.")
            let products = (try await currentTask?.value) ?? []
            return products
        }
        
        currentTask = Task<[Product], Error> {
            guard cachedProducts.isEmpty else {
                logger.debug("Using cached products.")
                return cachedProducts
            }
            
            logger.debug("No cached products. Start products loading.")
            
            let rawProducts = try await requester.requestProducts()
            return rawProducts.map { productsInfo in Product(identifier: productsInfo.0, devices: productsInfo.1) }
        }
        
        cachedProducts = (try await currentTask?.value) ?? []
        currentTask = nil
        
        return cachedProducts
    }
    
}

// MARK: - ProductsRequester

final class ProductsRequesterImpl: ProductsRequester {
    
    // MARK: - Internal Methods
    
    func requestProducts() async throws -> [(String, Int)] {
        let token = try await requestToken()
        let products = try await requestProducts(with: token)
        
        return products
    }
    
    // MARK: - Private Methods
    
    private func requestToken() async throws -> String {
        let (_, _) = try await URLSession.shared.data(from: URL(string: "https://httpbin.org/get")!)
        return "AHBcJLSBAjkSAJHBCKAcsaJKACBkaskABSCkaakdlonaO"
    }
    
    private func requestProducts(with token: String) async throws -> [(String, Int)] {
        let (_, _) = try await URLSession.shared.data(from: URL(string: "https://httpbin.org/get")!)
        return [
            ("monthSubscription", 1),
            ("monthSubscription", 5),
            ("yearSubscription", 10)
        ]
    }
    
}
