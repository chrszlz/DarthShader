//
//  Bundle+Additions.swift
//  Shades
//
//  Created by Chris Zelazo on 2/18/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import Foundation

public extension Bundle {
    
    public static func read(_ filepath: String, ofType: String?, bundle: Bundle = .main) -> String? {
        if let shaderPath = bundle.path(forResource: filepath, ofType: ofType) {
            do {
                return try String(contentsOfFile: shaderPath, encoding: .utf8)
            } catch {
                print("Bundle[\(bundle.debugDescription)] error reading from \(filepath).\(ofType ?? "<no type>") - \(error)")
            }
        } else {
            print("Bundle[\(bundle.debugDescription)] error locating \(filepath).\(ofType ?? "<no type>")")
        }
        return nil
    }
    
}
