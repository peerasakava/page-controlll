//
//  SimpleCollectionView.swift
//  PageControllll
//

import UIKit
import SnapKit

class SimpleCollectionView: UIViewController {
    
    // MARK: - Properties
    
    var pageBackgroundColor: UIColor = .white
    var products: [Product] = []
    var offsetY: CGFloat? = nil
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SimpleCVC.self,
                                forCellWithReuseIdentifier: SimpleCVC.identifier)
        return collectionView
    }()
    
    // MARK: - Initialization
    
    init(backgroundColor: UIColor = .white,
         products: [Product] = [],
         offsetY: CGFloat? = nil
    ) {
        self.pageBackgroundColor = backgroundColor
        self.products = products
        self.offsetY = offsetY
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let headerHeight = 200.0
        let menuHeights = (60.0) * 2.0
        let topInset = headerHeight + menuHeights
        let minimumHeight = view.frame.height - topInset - 16
        
        // Apply top inset immediately
        self.collectionView.contentInset.top = topInset
        
        // Calculate bottom inset after layout
        DispatchQueue.main.async {
            let contentHeight = self.collectionView.contentSize.height
            let bottomInset = contentHeight < minimumHeight ? minimumHeight : 0
            self.collectionView.contentInset.bottom = bottomInset
            
            // Apply saved offset if available
            if let offsetY = self.offsetY {
                self.collectionView.contentOffset = .init(x: 0, y: offsetY)
            }
        }
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = pageBackgroundColor
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func getCollectionViewContentOffset() -> CGPoint {
        return collectionView.contentOffset
    }
    
    func addScrollListener(_ listener: @escaping (CGFloat) -> Void) {
        scrollListener = listener
    }
    
    func updateProducts(_ products: [Product]) {
        self.products = products
        collectionView.reloadData()
    }
    
    // MARK: - Private Properties
    
    private var scrollListener: ((CGFloat) -> Void)?
}

// MARK: - UICollectionViewDataSource
extension SimpleCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.isEmpty ? 20 : products.count // Default item count for testing if no products
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimpleCVC.identifier, for: indexPath) as? SimpleCVC else {
            return UICollectionViewCell()
        }
        
        if products.isEmpty {
            cell.configure(with: "Item \(indexPath.row + 1)")
        } else {
            cell.configure(with: products[indexPath.row])
        }
        
        cell.backgroundColor = .red.withAlphaComponent(0.2)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SimpleCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60) // Fixed height for table-like rows
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Notify listener about scroll position
        let offsetY = scrollView.contentOffset.y + scrollView.contentInset.top
        scrollListener?(offsetY)
    }
} 
