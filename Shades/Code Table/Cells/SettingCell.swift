//
//  SettingCell.swift
//  Shades
//
//  Created by Chris Zelazo on 4/7/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit

public class SettingCell: UITableViewCell {
    
    private let theme = DefaultSourceCodeTheme()
    
    private lazy var control: UIButton = {
        let button = UIButton()
        button.setTitle("Record", for: .normal)
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        backgroundColor = theme.backgroundColor
        
        contentView.addSubview(control)
        NSLayoutConstraint.activate([
            control.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            control.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])
        control.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc private func handleTap() {

    }
    
}
