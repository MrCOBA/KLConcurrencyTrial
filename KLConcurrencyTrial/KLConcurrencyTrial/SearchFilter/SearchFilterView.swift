import SwiftUI
import OSLog

// MARK: - SearchView

struct SearchFilterView: View {
    
    // MARK: - Internal Properties
    
    @ObservedObject var provider: SearchQueryResultsProvider
    
    var body: some View {
        NavigationView {
            List(provider.results) { result in
                SearchResultView(result: result)
            }
            .searchable(text: $provider.query)
            .navigationBarTitle(Text("Search Results"))
        }
        .task {
            do {
                try await provider.getResult()
            }
            catch {
                logger.error("Error: <\(error.localizedDescription)>")
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let logger = Logger()
    
}

// MARK: - SearchResultView

struct SearchResultView: View {
    
    // MARK: - Internal Properties
    
    var result: SearchQueryResultObject
    
    var body: some View {
        HStack {
            Text(String(result.id))
            Spacer()
            Text(String(result.data))
        }
    }
    
}
