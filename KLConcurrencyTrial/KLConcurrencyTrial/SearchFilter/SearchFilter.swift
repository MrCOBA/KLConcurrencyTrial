import AsyncAlgorithms
import Foundation

struct SearchQueryResultObject: Identifiable {
    var id: String
    var data: String
}

@MainActor
final class SearchQueryResultsProvider: ObservableObject {
    
    // MARK: - Internal Properties
    
    @Published var results = [SearchQueryResultObject]()
    @Published var query: String = ""
    
    // MARK: - Internal Methods
    
    func getResult() async throws {
        let resultsStream = AsyncThrowingStream { [weak self] in
            try await self?.getQueryList()
        }
        
        let queryStream = $query.debounce(for: 0.5, scheduler: DispatchQueue.main).values
        
        for try await (results, query) in combineLatest(resultsStream, queryStream) {
            self.results = results.filter {
                query.isEmpty || $0.data.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func getQueryList() async throws -> [SearchQueryResultObject] {
        // Here may be some custom logic of getiing result 🤔
        return []
    }
    
}
