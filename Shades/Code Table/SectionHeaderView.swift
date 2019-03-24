//
//  SectionHeaderView.swift
//  Shades
//
//  Created by Chris Zelazo on 2/24/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit

public protocol SectionHeaderViewDelegate {
    func toggleSection(_ header: SectionHeaderView, section: Int)
}

public class SectionHeaderView: UITableViewHeaderFooterView {
    
    public var section: Int = 0
    
    public var delegate: SectionHeaderViewDelegate?
    
    public var isCollapsed: Bool = false {
        didSet {
            configure()
        }
    }
    
    private lazy var tapRecognizer = UITapGestureRecognizer()
    
    public lazy var titleLabel = UILabel()
    private lazy var arrowLabel = UILabel()
    
    private lazy var containerView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12.0
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()
    
    public override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            guard newValue.width != 0 && newValue.height != 0 else {
                return
            }
            super.frame = newValue
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Setup
        tintColor = .clear
        backgroundView = .clear
        
        contentView.backgroundColor = UIColor(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 0.6)
        
        contentView.addSubview(containerView)
        
        containerView.addArrangedSubview(titleLabel)
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Menlo-Bold", size: 18.0)
        
        containerView.addArrangedSubview(arrowLabel)
        arrowLabel.textColor = UIColor(red:0.98, green:0.71, blue:0.07, alpha:1.00)
        arrowLabel.font = UIFont(name: "Menlo", size: 16.0)
        
        // Layout
        let contentViewMargins = contentView.layoutMarginsGuide
        containerView.topAnchor.constraint(equalTo: contentViewMargins.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentViewMargins.leadingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentViewMargins.bottomAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentViewMargins.trailingAnchor).isActive = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        configure()
        
        tapRecognizer.addTarget(self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        // Arrow Label
        switch isCollapsed {
        case true:
            arrowLabel.text = "[+]"
        case false:
            arrowLabel.text = "[-]"
        }
    }
    
    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let header = recognizer.view as? SectionHeaderView else {
            return
        }
        delegate?.toggleSection(header, section: header.section)
    }
}
