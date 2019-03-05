//
//  UIView+Additions.swift
//  Shades
//
//  Created by Chris Zelazo on 2/25/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit

public extension UIView {
    
    /// A `.zero` frame view with a clear `backgroundColor`.
    public static var clear: UIView = UIView.color(.clear)
    
    public static func color(_ color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
    
    // MARK: - Blurs
    
    public static var blur: UIVisualEffectView = UIView.blurView(style: .regular)
    
    public static var prominentBlur: UIVisualEffectView = UIView.blurView(style: .prominent)
    
    public static var lightBlur: UIVisualEffectView = UIView.blurView(style: .light)
    
    public static var darkBlur: UIVisualEffectView = UIView.blurView(style: .dark)
    
    private static func blurView(style: UIBlurEffect.Style) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.clipsToBounds = true
        return view
    }
    
}
