//
//  SimpleCollectionView.swift
//  PageControllll
//

import UIKit
import SnapKit

class SimpleCollectionView: UIViewController {
    
    // MARK: - Properties
    
    var pageTitle: String = "Default Page"
    var pageBackgroundColor: UIColor = .white
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
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
        collectionView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    // MARK: - Initialization
    
    init(title: String = "Default Page", backgroundColor: UIColor = .white) {
        self.pageTitle = title
        self.pageBackgroundColor = backgroundColor
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
        
        view.addSubview(titleLabel)
        titleLabel.text = pageTitle
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func getCollectionViewContentOffset() -> CGPoint {
        return collectionView.contentOffset
    }
    
    func addScrollListener(_ listener: @escaping (CGFloat) -> Void) {
        scrollListener = listener
    }
    
    // MARK: - Private Properties
    
    private var scrollListener: ((CGFloat) -> Void)?
}

// MARK: - UICollectionViewDataSource
extension SimpleCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20 // Default item count for testing
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SimpleCVC.identifier, for: indexPath) as? SimpleCVC else {
            return UICollectionViewCell()
        }
        cell.configure(with: "Item \(indexPath.row + 1)")
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