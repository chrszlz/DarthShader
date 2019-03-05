//
//  Math+Additions.swift
//  Shades
//
//  Created by Chris Zelazo on 3/5/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import Foundation

public extension FloatingPoint {
    
    // Interpolates `value` between `bounds` mapping an output between `outputBounds`.
    public static func lerp(value: Self, between bounds: (Self, Self), outputBounds: (Self, Self)) -> Self {
        return value.lerp(bounds: bounds, outputBounds: outputBounds)
    }
    
    // Interpolates a value `self` between `bounds` mapping an output between `outputBounds`.
    public func lerp(bounds: (Self, Self), outputBounds: (Self, Self)) -> Self {
        return outputBounds.0 + ((self - bounds.0) / (bounds.1 - bounds.0) * (outputBounds.1 - outputBounds.0))
    }
    
}
