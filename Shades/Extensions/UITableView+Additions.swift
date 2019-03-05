//
//  UITableView+Additions.swift
//  Shades
//
//  Created by Chris Zelazo on 2/18/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit

public extension UITableView {
    
    // Registers a given class as a reusable cell using the standard reuse
    // naming convention, e.g. `Redux.CommentCell`.
    public func register<T: UITableViewCell>(reusableCell type: T.Type) {
        register(T.self, forCellReuseIdentifier: String(describing: type))
    }
    
    // Registers a given class as a reusable header/footer cell using the standard reuse
    // naming convention, e.g. `Redux.CommentCell`.
    public func register<T: UITableViewHeaderFooterView>(reusableHeaderFooter type: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: String(describing: type))
    }
    
    // Dequeues a cell of the specified type at an index path.
    // Note: Uses name of class as identifier, e.g. `Redux.CommentCell`. Ensure
    // the cell's Storyboard identifier matches this convention.
    public func dequeue<T>(reusableCell type: T.Type, indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as? T else {
            fatalError("Couldn't find UITableViewCell for \(String(describing: type))")
        }
        return cell
    }
    
    // Dequeues a cell of the specified type at an index path.
    // Note: Uses name of class as identifier, e.g. `Redux.CommentCell`. Ensure
    // the cell's Storyboard identifier matches this convention.
    public func dequeue<T>(reusableHeaderFooterCell type: T.Type) -> T {
        guard let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: String(describing: type)) as? T else {
            fatalError("Couldn't find UITableViewHeaderFooterView for \(String(describing: type))")
        }
        return headerFooter
    }
    
    public func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
    public enum Direction {
        case top
        case bottom
    }
    
    public func scroll(to: UITableView.Direction, animated: Bool = true) {
        let yOffset: CGFloat
        switch to {
        case .top:
            yOffset = 0
        case .bottom:
            yOffset = contentSize.height - bounds.size.height
        }
        setContentOffset(CGPoint(x: 0, y: yOffset), animated: animated)
    }
 
}
