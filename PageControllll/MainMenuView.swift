import UIKit
import SnapKit

protocol MainMenuViewDelegate: AnyObject {
    func mainMenuView(_ menuView: MainMenuView, didSelectMenuAt index: Int)
}

class MainMenuView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: MainMenuViewDelegate?
    private var buttons: [UIButton] = []
    private var selectedIndex: Int = 0
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()
    
    lazy var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupButtons()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        backgroundColor = .white
        
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
    
    private func setupButtons() {
        let titles = ["Core Offerings", "Research & Development"]
        
        // Clear existing buttons
        buttons.forEach { $0.removeFromSuperview() }
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        buttons = []
        
        // Create buttons for each title
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            button.setTitleColor(index == selectedIndex ? .systemRed : .darkGray, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            stackView.addArrangedSubview(button)
            buttons.append(button)
        }
        
        updateIndicator(animated: false)
    }
    
    // MARK: - Public Methods
    
    func setSelectedIndex(_ index: Int, animated: Bool = true) {
        guard index >= 0 && index < buttons.count else { return }
        
        // Update button colors
        for (i, button) in buttons.enumerated() {
            button.setTitleColor(i == index ? .systemRed : .darkGray, for: .normal)
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
        delegate?.mainMenuView(self, didSelectMenuAt: sender.tag)
    }
} 
