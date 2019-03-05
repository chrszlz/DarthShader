//
//  UIKit+Additions.swift
//  Shades
//
//  Created by Chris Zelazo on 3/5/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit

public extension UITouch {
    
    /// Normalized force value
    public var normalizedForce: CGFloat {
        return force / maximumPossibleForce
    }
    
}
