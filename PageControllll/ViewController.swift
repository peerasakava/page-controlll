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
    
    lazy var mainHeaderView: UIView = {
        let mainHeaderView = UIView()
        mainHeaderView.backgroundColor = .yellow.withAlphaComponent(0.5)
        return mainHeaderView
    }()
    
    lazy var mainMenuView: MainMenuView = {
        let mainMenuView = MainMenuView()
        mainMenuView.backgroundColor = .white.withAlphaComponent(0.8)
        mainMenuView.delegate = self
        return mainMenuView
    }()

    lazy var menuView: CategoryMenuView = {
        let menuView = CategoryMenuView()
        menuView.backgroundColor = .green.withAlphaComponent(0.5)
        menuView.delegate = self
        return menuView
    }()
    
    lazy var navigationBar: UIView = {
        let navBar = UIView()
        navBar.backgroundColor = .brown.withAlphaComponent(0.4)
        return navBar
    }()
    
    private var collectionPages: [SimpleCollectionView] = []
    private var currentCategories: [Category] = []
    private var pageCount: Int { return currentCategories.count }

    private let navBarHeight: CGFloat = 60
    private let mainHeaderHeight: CGFloat = 200
    private let mainMenuHeight: CGFloat = 60
    private let menuHeight: CGFloat = 60
    
    private var storedOffsetY: CGFloat? = nil
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Default to Core Offerings
        currentCategories = Category.coreOfferings
        
        setupViews()
        setupChildViewControllers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update content size for horizontal scrolling
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(pageCount),
                                        height: scrollView.frame.height)
        
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
            make.bottom.equalToSuperview()
        }
    
        // Add main header view
        view.addSubview(mainHeaderView)
        mainHeaderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(mainHeaderHeight)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(navBarHeight)
        }
        
        // Add main menu view
        view.addSubview(mainMenuView)
        mainMenuView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(mainMenuHeight)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(navBarHeight + mainHeaderHeight)
        }
        
        // Add menu view
        view.addSubview(menuView)
        menuView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(menuHeight)
            make.top.equalTo(mainMenuView.snp.bottom)
        }
        
        // Add navigation bar
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(navBarHeight)
        }
    }
    
    private func setupChildViewControllers() {
        // Remove existing child view controllers
        for childVC in collectionPages {
            childVC.willMove(toParent: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParent()
        }
        collectionPages.removeAll()
        
        // Create titles from categories
        let titles = currentCategories.map { $0.name }
        
        for i in 0..<pageCount {
            let category = currentCategories[i]
            
            let collectionViewController = SimpleCollectionView(
                backgroundColor: .white,
                products: category.products,
                offsetY: storedOffsetY
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
        
        // Reset to first page
        if !titles.isEmpty {
            menuView.setSelectedIndex(0)
        }
        
        guard let storedOffsetY else { return }
        synchronizeContentOffsets(offsetY: storedOffsetY)
    }
    
    // MARK: - Menu Positioning
    
    private func updateMenuPosition(with offsetY: CGFloat) {
        let mainHeaderTranslationY = max(-(mainHeaderHeight), -offsetY)
        let mainMenuTranslationY = max(-(mainHeaderHeight + mainMenuHeight - navBarHeight), -offsetY)
        let menuTranslationY = max(-(mainHeaderHeight + menuHeight - navBarHeight), -offsetY)

        self.mainMenuView.transform = CGAffineTransform(translationX: 0,
                                                        y: mainMenuTranslationY)
        self.menuView.transform = CGAffineTransform(translationX: 0,
                                                    y: menuTranslationY)
        self.mainHeaderView.transform = CGAffineTransform(translationX: 0,
                                                          y: mainHeaderTranslationY)
    }
    
    // MARK: - Actions
    
    private func switchToMenuType(_ index: Int) {
        // 0 = Core Offerings, 1 = Research & Development
        switch index {
        case 0:
            currentCategories = Category.coreOfferings
        case 1:
            currentCategories = Category.researchAndDevelopment
        default:
            currentCategories = Category.coreOfferings
        }
        
        setupChildViewControllers()
        view.layoutIfNeeded()
    }
}

// MARK: - UIScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        menuView.setSelectedIndex(currentPage)
        
        // Synchronize all pages to match the current page's offset
        synchronizeContentOffsets(currentPageIndex: currentPage)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
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
        guard !collectionPages.isEmpty, currentPageIndex < collectionPages.count else { return }
        
        let currentPageView = collectionPages[currentPageIndex]
        
        for (index, page) in collectionPages.enumerated() {
            if index != currentPageIndex {
                let currentOffset = currentPageView.collectionView.contentOffset
                let nextOffsetY = min(-(mainMenuHeight + menuHeight), currentOffset.y)
                page.collectionView.setContentOffset(.init(x: 0,
                                                            y: nextOffsetY),
                                                    animated: false)
            }
        }
    }
    
    private func synchronizeContentOffsets(offsetY: CGFloat) {
        for page in collectionPages {
            page.collectionView.setContentOffset(.init(x: 0,
                                                       y: offsetY),
                                                 animated: false)
        }
    }
    
    private func updateStoredOffset() {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        let currentPageView = collectionPages[currentPage]
        storedOffsetY = currentPageView.collectionView.contentOffset.y
    }
}

// MARK: - CategoryMenuViewDelegate
extension ViewController: CategoryMenuViewDelegate {
    func categoryMenuView(_ menuView: CategoryMenuView, didSelectPageAt index: Int) {
        let offsetX = scrollView.frame.width * CGFloat(index)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
        synchronizeContentOffsets(currentPageIndex: currentPage)
    }
}

// MARK: - MainMenuViewDelegate
extension ViewController: MainMenuViewDelegate {
    func mainMenuView(_ menuView: MainMenuView, didSelectMenuAt index: Int) {
        updateStoredOffset()
        switchToMenuType(index)
    }
}

