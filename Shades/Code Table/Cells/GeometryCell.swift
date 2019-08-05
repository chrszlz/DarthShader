//
//  GeometryCell.swift
//  Shades
//
//  Created by Chris Zelazo on 3/24/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit

protocol GeometryCellDelegate {
    func geometryControlDidSelect(geometry: Geometry)
}

final class GeometryCell: UITableViewCell {
    
    private let theme = DefaultSourceCodeTheme()
    
    public var delegate: GeometryCellDelegate?
    
    public lazy var control: UISegmentedControl = {
        let control = UISegmentedControl()
        control.apportionsSegmentWidthsByContent = true
        control.backgroundColor = .clear
        control.tintColor = .clear
        control.setTitleTextAttributes([
            .font : theme.font.withSize(16.0),
            .foregroundColor: DefaultSourceCodeTheme.lineNumbersColor
            ], for: .normal)
        
        control.setTitleTextAttributes([
            .font : theme.font.withSize(16.0),
            .foregroundColor: UIColor(red:0.98, green:0.71, blue:0.07, alpha:1.00)
            ], for: .selected)
        
        control.addTarget(self, action: #selector(handleControlSelection(_:)), for: .valueChanged)
        return control
    }()
    
    public var model: GeometryModel? {
        didSet {
            configure()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        sharedInit()
    }
    
    private func sharedInit() {
        backgroundColor = theme.backgroundColor
        
        contentView.addSubview(control)
        NSLayoutConstraint.activate([
            control.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            control.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            control.heightAnchor.constraint(equalToConstant: 16.0)
            ])
        control.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        delegate = nil
    }
    
    private func configure() {
        control.removeAllSegments()
        
        guard let model = model else {
            return
        }
        
        model.geometries.enumerated().forEach { (arg) in
            let (i, geometry) = arg
            control.insertSegment(withTitle: geometry.rawValue, at: i, animated: true)
        }
        
        if control.numberOfSegments > 0 {
            control.selectedSegmentIndex = 0
        }
    }
    
    @objc private func handleControlSelection(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        guard let model = model, index < model.geometries.count else {
            assertionFailure("[Error] Unable to handle geometry selection")
            return
        }
        let geometry = model.geometries[index]
        delegate?.geometryControlDidSelect(geometry: geometry)
    }
}
