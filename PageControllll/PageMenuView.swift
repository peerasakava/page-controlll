//
//  PageMenuView.swift
//  PageControllll
//

import UIKit
import SnapKit

protocol PageMenuViewDelegate: AnyObject {
    func pageMenuView(_ menuView: PageMenuView, didSelectPageAt index: Int)
}

class PageMenuView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: PageMenuViewDelegate?
    private var buttons: [UIButton] = []
    private var selectedIndex: Int = 0
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 2
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 4, right: 16))
        }
        
        addSubview(indicatorView)
        indicatorView.snp.makeConstraints { make in
            make.height.equalTo(4)
            make.bottom.equalToSuperview()
            make.width.equalTo(0)
            make.centerX.equalTo(self.snp.leading)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(with titles: [String]) {
        // Clear existing buttons
        buttons.forEach { $0.removeFromSuperview() }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons = []
        
        // Create buttons for each title
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            button.setTitleColor(index == selectedIndex ? .systemBlue : .darkGray, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }
        
        updateIndicator(animated: false)
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool = true) {
        guard index >= 0 && index < buttons.count else { return }
        
        // Update button colors
        for (i, button) in buttons.enumerated() {
            button.setTitleColor(i == index ? .systemBlue : .darkGray, for: .normal)
        }
        
        selectedIndex = index
        updateIndicator(animated: animated)
    }
    
    // MARK: - Private Methods
    
    private func updateIndicator(animated: Bool) {
        guard !buttons.isEmpty, selectedIndex < buttons.count else { return }
        
        let button = buttons[selectedIndex]
        let duration = animated ? 0.3 : 0
        
        UIView.animate(withDuration: duration) {
            self.indicatorView.snp.remakeConstraints { make in
                make.height.equalTo(4)
                make.bottom.equalToSuperview()
                make.width.equalTo(button.titleLabel?.intrinsicContentSize.width ?? 0)
                make.centerX.equalTo(button)
            }
            self.layoutIfNeeded()
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        setSelectedIndex(sender.tag)
        delegate?.pageMenuView(self, didSelectPageAt: sender.tag)
    }
} 