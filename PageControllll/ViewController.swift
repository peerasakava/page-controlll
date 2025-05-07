//
//  ViewController.swift
//  PageControllll
//
//  Created by Peerasak Unsakon on 7/5/2568 BE.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .darkGray
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)
        return pageControl
    }()
    
    lazy var menuView: PageMenuView = {
        let menuView = PageMenuView()
        menuView.delegate = self
        return menuView
    }()
    
    private var collectionPages: [SimpleCollectionView] = []
    private let pageCount = 3
    private let menuHeight: CGFloat = 100
    private let menuIntialY: CGFloat = 300
    private let maxMenuOffset: CGFloat = 400
    private let minMenuOffset: CGFloat = 60
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupChildViewControllers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update content size for horizontal scrolling
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(pageCount), height: scrollView.frame.height)
        
        // Update frames of child view controllers
        for (index, childVC) in collectionPages.enumerated() {
            childVC.view.frame = CGRect(
                x: scrollView.frame.width * CGFloat(index),
                y: 0,
                width: scrollView.frame.width,
                height: scrollView.frame.height
            )
        }
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }
        
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        // Add menu view
        view.addSubview(menuView)
        menuView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(menuHeight)
            make.top.equalToSuperview().offset(menuIntialY) // Initial position at 200pt from top
        }
    }
    
    private func setupChildViewControllers() {
        // Create 3 SimpleCollectionView instances with different colors
        let colors: [UIColor] = [
            .clear, .clear, .clear
        ]
        
        let titles = ["Page One", "Page Two", "Page Three"]
        
        for i in 0..<pageCount {
            let collectionViewController = SimpleCollectionView(
                title: titles[i],
                backgroundColor: colors[i]
            )
            addChild(collectionViewController)
            scrollView.addSubview(collectionViewController.view)
            collectionViewController.didMove(toParent: self)
            
            // Add scroll listener to update menu position
            collectionViewController.addScrollListener { [weak self] offsetY in
                self?.updateMenuPosition(with: offsetY)
            }
            
            collectionPages.append(collectionViewController)
        }
        
        // Configure menu with page titles
        menuView.configure(with: titles)
    }
    
    // MARK: - Menu Positioning
    
    private func updateMenuPosition(with offsetY: CGFloat) {
        // Calculate new Y position for menu
        // offsetY will be negative when scrolling down from the top
        let translationY = min(maxMenuOffset - menuIntialY, max(minMenuOffset - menuIntialY, -offsetY))
        
        // Apply transform instead of updating constraints
        self.menuView.transform = CGAffineTransform(translationX: 0, y: translationY)
    }
    
    // MARK: - Actions
    
    @objc private func pageControlValueChanged(_ sender: UIPageControl) {
        let offsetX = scrollView.frame.width * CGFloat(sender.currentPage)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        menuView.setSelectedIndex(sender.currentPage)
    }
}

// MARK: - UIScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = currentPage
        menuView.setSelectedIndex(currentPage)
        
        // Synchronize all pages to match the current page's offset
        synchronizeContentOffsets(currentPageIndex: currentPage)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = currentPage
        menuView.setSelectedIndex(currentPage)
        
        // Synchronize all pages to match the current page's offset
        synchronizeContentOffsets(currentPageIndex: currentPage)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Get the current page index
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        
        // Synchronize all other pages to match the current page's offset
        synchronizeContentOffsets(currentPageIndex: currentPage)
    }
    
    // MARK: - Helper Methods
    
    private func synchronizeContentOffsets(currentPageIndex: Int) {
        let currentPageView = collectionPages[currentPageIndex]
        
        for (index, page) in collectionPages.enumerated() {
            if index != currentPageIndex {
                page.collectionView.setContentOffset(currentPageView.collectionView.contentOffset, animated: false)
            }
        }
    }
}

// MARK: - PageMenuViewDelegate
extension ViewController: PageMenuViewDelegate {
    func pageMenuView(_ menuView: PageMenuView, didSelectPageAt index: Int) {
        let offsetX = scrollView.frame.width * CGFloat(index)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        pageControl.currentPage = index
    }
}

