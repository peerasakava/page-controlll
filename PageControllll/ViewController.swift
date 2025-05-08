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
        mainHeaderView.backgroundColor = .yellow
        return mainHeaderView
    }()
    
    lazy var mainMenuView: MainMenuView = {
        let mainMenuView = MainMenuView()
        mainMenuView.delegate = self
        return mainMenuView
    }()

    lazy var menuView: PageMenuView = {
        let menuView = PageMenuView()
        menuView.delegate = self
        return menuView
    }()
    
    private var collectionPages: [SimpleCollectionView] = []
    private var currentCategories: [Category] = []
    private var pageCount: Int {
        return currentCategories.count
    }

    private let mainHeaderHeight: CGFloat = 300
    private let mainHeaderInitialY: CGFloat = 60
    private let maxMainHeaderOffset: CGFloat = 400
    private let minMainHeaderOffset: CGFloat = -300

    private let mainMenuHeight: CGFloat = 60
    private let mainMenuInitialY: CGFloat = 240
    
    private let menuHeight: CGFloat = 60
    private let menuIntialY: CGFloat = 300
    private let maxMenuOffset: CGFloat = 500
    
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
            make.bottom.equalToSuperview()
        }
        
        // Add main header view
        view.addSubview(mainHeaderView)
        mainHeaderView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(mainHeaderHeight)
            make.top.equalToSuperview().offset(mainHeaderInitialY)
        }
        
        // Add main menu view
        view.addSubview(mainMenuView)
        mainMenuView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(mainMenuHeight)
            make.top.equalToSuperview().offset(mainMenuInitialY)
        }
        
        // Add menu view
        view.addSubview(menuView)
        menuView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(menuHeight)
            make.top.equalToSuperview().offset(menuIntialY)
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
        
        // Create background colors
        let colors: [UIColor] = [
            .orange.withAlphaComponent(0.5),
            .cyan.withAlphaComponent(0.5),
            .green.withAlphaComponent(0.5),
            .purple.withAlphaComponent(0.5)
        ]
        
        // Create titles from categories
        let titles = currentCategories.map { $0.name }
        
        for i in 0..<pageCount {
            let category = currentCategories[i]
            let colorIndex = i % colors.count
            
            let collectionViewController = SimpleCollectionView(
                backgroundColor: colors[colorIndex],
                products: category.products
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
    }
    
    // MARK: - Menu Positioning
    
    private func updateMenuPosition(with offsetY: CGFloat) {
        // Calculate new Y position for menu and main menu
        // offsetY will be negative when scrolling down from the top
        
        let mainMenuTranslationY = min(maxMenuOffset - mainMenuInitialY, max(view.safeAreaInsets.top - mainMenuInitialY, -offsetY))
        let menuTranslationY = min(maxMenuOffset - menuIntialY, max(view.safeAreaInsets.top - menuIntialY + mainMenuHeight, -offsetY))
        let mainHeaderTranslationY = min(maxMainHeaderOffset - mainHeaderInitialY, max((minMainHeaderOffset + view.safeAreaInsets.top + menuHeight) - mainHeaderInitialY, -offsetY))
        
        // Apply transform instead of updating constraints
        self.mainMenuView.transform = CGAffineTransform(translationX: 0, y: mainMenuTranslationY)
        self.menuView.transform = CGAffineTransform(translationX: 0, y: menuTranslationY)
        self.mainHeaderView.transform = CGAffineTransform(translationX: 0, y: mainHeaderTranslationY)
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
                let nextOffsetY = min(-(menuHeight + mainMenuHeight), currentOffset.y) 
                page.collectionView.setContentOffset(.init(x: 0,
                                                            y: nextOffsetY),
                                                    animated: false)
            }
        }
    }
}

// MARK: - PageMenuViewDelegate
extension ViewController: PageMenuViewDelegate {
    func pageMenuView(_ menuView: PageMenuView, didSelectPageAt index: Int) {
        let offsetX = scrollView.frame.width * CGFloat(index)
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
}

// MARK: - MainMenuViewDelegate
extension ViewController: MainMenuViewDelegate {
    func mainMenuView(_ menuView: MainMenuView, didSelectMenuAt index: Int) {
        switchToMenuType(index)
    }
}

