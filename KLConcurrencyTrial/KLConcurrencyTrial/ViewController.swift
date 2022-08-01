import UIKit
import OSLog

class ViewController: UIViewController {

    private var productsProvider: ProductsProvider?
    private let logger = Logger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let productsRequester = ProductsRequesterImpl()
        productsProvider = ProductsProviderImpl(requester: productsRequester)
    }

    // Provider Testing 😑
    @MainActor
    @IBAction func loadButtonTapped(_ sender: Any) {
        Task {
            let products = (try? await productsProvider?.getProducts()) ?? []
            
            guard !products.isEmpty else {
                logger.debug("Received empty products list 😒")
                return
            }
            
            logger.debug("Products loaded successfully 😃")
        }
    }
    
}

