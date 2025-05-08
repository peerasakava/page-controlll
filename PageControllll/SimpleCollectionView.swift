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
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SimpleCVC.self, forCellWithReuseIdentifier: SimpleCVC.identifier)
        let topInset = 300.0
        let minimumHeight = view.frame.height - topInset
        let rowHeight = 60.0
        let bottomInset = CGFloat(products.count) * rowHeight < minimumHeight ? minimumHeight : 0
        collectionView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
        return collectionView
    }()
    
    // MARK: - Initialization
    
    init(backgroundColor: UIColor = .white, products: [Product] = []) {
        self.pageBackgroundColor = backgroundColor
        self.products = products
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
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = pageBackgroundColor
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
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
