//
//  UIKit+Additions.swift
//  Shades
//
//  Created by Chris Zelazo on 3/5/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

public extension UIApplication {
    
    static var statusBarSize: CGSize {
        return UIApplication.shared.statusBarFrame.size
    }
    
}

public extension UITouch {
    
    /// UITouch force value normalized to [0, 1]
    var normalizedForce: CGFloat {
        return force / maximumPossibleForce
    }
    
}

//Since 3D Touch isn't available before iOS 9, we can use the availability APIs to ensure no one uses this class for earlier versions of the OS.
@available(iOS 9.0, *)
public class ForceTouchGestureRecognizer: UIGestureRecognizer {

    /// Force value normalized from [0.0, 1.0], representing no force to max force.
    public private(set) var force: CGFloat = 0.0
    public var maximumForce: CGFloat = 4.0
    
    /// Minimum normalized force value to trigger recognizer and move to `began` state.
    public var minimumForceActivation: CGFloat = 0.1
    
    convenience init() {
        self.init(target: nil, action: nil)
    }
    
    //We override the initializer because UIGestureRecognizer's cancelsTouchesInView property is true by default. If you were to, say, add this recognizer to a tableView's cell, it would prevent didSelectRowAtIndexPath from getting called. Thanks for finding this bug, Jordan Hipwell!
    public override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        cancelsTouchesInView = false
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        normalizeForce(touches)
        
        guard touches.force > minimumForceActivation else {
            return
        }
        state = .began
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        normalizeForce(touches)

        let validStates: [UIGestureRecognizer.State] = [.began, .changed]
        if validStates.contains(state) {
            // Continue handling events
            state = .changed
        } else if touches.force > minimumForceActivation {
            // Begin gesture recognizing, move to `began`.
            state = .began
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        normalizeForce(touches)
        
        let validStates: [UIGestureRecognizer.State] = [.began, .changed]
        guard validStates.contains(state) else {
            return
        }
        state = .ended
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        normalizeForce(touches)
        
        guard state != .possible else {
            return
        }
        state = .cancelled
    }
    
    private func normalizeForce(_ touches: Set<UITouch>) {
        //Putting a guard statement here to make sure we don't fire off our target's selector event if a touch doesn't exist to begin with.
        guard let firstTouch = touches.first else { return }
        
        //Just in case the developer set a maximumForce that is higher than the touch's maximumPossibleForce, I'm setting the maximumForce to the lower of the two values.
        maximumForce = min(firstTouch.maximumPossibleForce, maximumForce)
        
        //Now that I have a proper maximumForce, I'm going to use that and normalize it so the developer can use a value between 0.0 and 1.0.
        force = firstTouch.force / maximumForce
    }
    
    //This function is called automatically by UIGestureRecognizer when our state is set to .Ended. We want to use this function to reset our internal state.
    public override func reset() {
        super.reset()
        force = 0.0
    }
}

fileprivate extension Set where Element == UITouch {
    
    /// Normalized force from [0, 1]
    var force: CGFloat {
        guard let touch = self.first else {
            return 0.0
        }
        return touch.force / touch.maximumPossibleForce
    }
    
}
