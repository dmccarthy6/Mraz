//  Created by Dylan  on 8/6/20.
//  Copyright © 2020 DylanMcCarthy. All rights reserved.

import UIKit

final class NextButton: UIButton {
    // MARK: - Properties
    var nextButtonTapped: EmptyClosure?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureNextButton()
        setButtonStateColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    func configureNextButton() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setImage(SystemImages.arrowRight, for: .normal)
        self.backgroundColor = .systemRed
        self.tintColor = .label
        self.clipsToBounds = true
        self.layer.cornerRadius = frame.width / 2
        self.addTarget(self, action: #selector(_nextButtonTapped), for: .touchUpInside)
        
    }
    
    @objc private func _nextButtonTapped() {
        nextButtonTapped?()
    }
    
    func setButtonStateColors() {
        self.setBackground(color: NextButtonColor.normal, for: .normal)
        self.setBackground(color: NextButtonColor.selected, for: .selected)
        self.setBackground(color: NextButtonColor.disabled, for: .disabled)
    }
}
