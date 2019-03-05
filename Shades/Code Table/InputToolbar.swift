//
//  InputToolbar.swift
//  Shades
//
//  Created by Chris Zelazo on 3/1/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit

public protocol ToolbarDelegate {
    func toolbarKeyPressed(_ toolbar: InputToolbar, key: InputToolbarKey, value: String)
}

public class InputToolbar: UIInputView, UIInputViewAudioFeedback, InputToolbarKeyDelegate {
    
    public let keys: [String] = [".", ",", ";", "(", ")", "*", "/", "+", "-", "="]
    
    public var delegate: ToolbarDelegate?
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6.0
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    
    convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 375, height: 53), inputViewStyle: .keyboard)
    }
    
    public override init(frame: CGRect, inputViewStyle: UIInputView.Style) {
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        sharedInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(stack)
        stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3.0).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.0).isActive = true
        stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3.0).isActive = true
        stack.topAnchor.constraint(equalTo: topAnchor, constant: 8.0).isActive = true
        stack.translatesAutoresizingMaskIntoConstraints  = false
        
        let items: [UIButton] = keys.map {
            let key = InputToolbarKey(title: "\($0)", value: "\($0)")
            key.delegate = self
            key.addTarget(self, action: #selector(playInputClick), for: .touchDown)
            return key
        }
        
        allowsSelfSizing = true
        
        items.forEach {
            stack.addArrangedSubview($0)
        }
    }
    
    
    // MARK: - UIInputViewAudioFeedback
    
    public var enableInputClicksWhenVisible: Bool {
        return true
    }
    
    @objc private func playInputClick() {
        UIDevice.current.playInputClick()
    }
    
    
    // MARK: - InputToolbarKeyDelegate
    
    public func keyPressed(key: InputToolbarKey, value: String) {
        delegate?.toolbarKeyPressed(self, key: key, value: value)
    }
}

public protocol InputToolbarKeyDelegate {
    func keyPressed(key: InputToolbarKey, value: String)
}

public class InputToolbarKey: UIButton {
    
    private static let backgroundColorNormal = UIColor(white: 1.0, alpha: 0.3)
    private static let backgroundColorSelected = UIColor(red: 0.89, green: 0.81, blue: 0.89, alpha: 1.0)
    
    public var delegate: InputToolbarKeyDelegate?
    
    public private(set) var value: String = ""
    
    public var isShowingShadow: Bool {
        return false
    }
    
    convenience init(title: String?, value: String) {
        self.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.value = value
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    private func sharedInit() {
        backgroundColor = InputToolbarKey.backgroundColorNormal
        
        titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .regular)
        
        setTitleColor(.white, for: .normal)
        
        layer.cornerRadius = 5.0
        layer.masksToBounds = false
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 7, right: 0)
        
        addTarget(self, action: #selector(handleKeyPress), for: .touchUpInside)
        
        if isShowingShadow {
            layer.shadowColor = UIColor(white: 0.0, alpha: 1.0).cgColor
            layer.shadowOpacity = 0.35
            layer.shadowRadius = 0.0
            layer.shadowOffset = CGSize(width: 0, height: 2.0)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if isShowingShadow {
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 5.0).cgPath
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        setTitleColor(.black, for: .normal)
        backgroundColor = InputToolbarKey.backgroundColorSelected
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        setTitleColor(.white, for: .normal)
        backgroundColor = InputToolbarKey.backgroundColorNormal
    }
    
    @objc private func handleKeyPress() {
        delegate?.keyPressed(key: self, value: value)
    }
    
}
