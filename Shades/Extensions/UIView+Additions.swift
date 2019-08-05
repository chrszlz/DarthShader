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
    static var clear: UIView = UIView.color(.clear)
    
    static func color(_ color: UIColor) -> UIView {
        let view = UIView()
        view.backgroundColor = color
        return view
    }
    
    // MARK: - Blurs
    
    static var blur: UIVisualEffectView = UIView.blurView(style: .regular)
    
    static var prominentBlur: UIVisualEffectView = UIView.blurView(style: .prominent)
    
    static var lightBlur: UIVisualEffectView = UIView.blurView(style: .light)
    
    static var darkBlur: UIVisualEffectView = UIView.blurView(style: .dark)
    
    private static func blurView(style: UIBlurEffect.Style) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.clipsToBounds = true
        return view
    }
    
}

public extension UISpringTimingParameters {
    
    /// A design-friendly way to create a spring timing curve.
    ///
    /// - Parameters:
    ///   - damping: The 'bounciness' of the animation. Value must be between 0 and 1.
    ///   - response: The 'speed' of the animation.
    ///   - initialVelocity: The vector describing the starting motion of the property. Optional, default is `.zero`.
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
    
}

public extension UIViewPropertyAnimator {
    
    /// A design-friendly way to create a spring timing curve. Note `duration`
    /// is automatically calculated.
    ///
    /// - Parameters:
    ///   - damping: The 'bounciness' of the animation. Value must be between 0 and 1.
    ///   - response: The 'speed' of the animation.
    ///   - initialVelocity: The vector describing the starting motion of the property. Optional, default is `.zero`.
    ///   - animations: Animation block that will be passed directly into the newly created UIViewPropertyAnimator
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero, animations: @escaping () -> Void) {
        let timingParameters = UISpringTimingParameters(damping: damping, response: response, initialVelocity: initialVelocity)
        let duration = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters).duration
        self.init(duration: duration, timingParameters: timingParameters)
        self.addAnimations(animations)
    }
    
}
