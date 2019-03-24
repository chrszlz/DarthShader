//
//  Section.swift
//  Shades
//
//  Created by Chris Zelazo on 3/22/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit
import SceneKit

// MARK: - Section

public struct Section {
    public var name: String
    public var items: [Item]
    public var isCollapsed: Bool
    
    init(_ name: String, items: [Item], isCollapsed: Bool = false) {
        self.name = name
        self.items = items
        self.isCollapsed = isCollapsed
    }
}

extension Array where Element == Section {
    
    var items: [Item] {
        return self.flatMap { $0.items }
    }
    
    @discardableResult
    public mutating func write(_ code: Shader, to indexPath: IndexPath) -> Bool {
        guard case .code(let snippet) = self[indexPath.section].items[indexPath.row] else {
            return false
        }
        self[indexPath.section].items[indexPath.row] = .code(Snippet(snippet.name, code: code, isFragmentShader: snippet.isFragmentShader))
        return true
    }
    
}

// MARK: - Items

/// Table wrapper item

infix operator ~=

public enum Item {
    case geometry(GeometryModel)
    case code(Snippet)
    
    public var isGeometry: Bool {
        if case .geometry(_) = self {
            return true
        } else {
            return false
        }
    }
    
    public var isCode: Bool {
        if case .code(_) = self {
            return true
        } else {
            return false
        }
    }
    
    public static func ~=(lhs: Item, rhs: Item) -> Bool {
        switch (lhs, rhs) {
        case (.geometry(_), .geometry(_)):
            return true
        case (.code(_), .code(_)):
            return true
        default:
            return false
        }
    }
}

/// Code Snippet
public struct Snippet {
    public var name: String
    public var code: Shader
    public var isFragmentShader: Bool
    
    init(_ name: String, code: String, isFragmentShader: Bool = false) {
        self.name = name
        self.code = code
        self.isFragmentShader = isFragmentShader
    }
}

/// Geometries Picker
public struct GeometryModel {
    public let geometries = Geometry.allCases
}

public enum Geometry: String, CaseIterable {
    case plane   = "Plane"
    case box     = "Box"
    case pyramid = "Pyramid"
    case sphere  = "Sphere"
    case torus   = "Torus"
    
    var type: SCNGeometry.Type {
        switch self {
        case .plane:   return SCNPlane.self
        case .box:     return SCNBox.self
        case .pyramid: return SCNPyramid.self
        case .sphere:  return SCNSphere.self
        case .torus:   return SCNTorus.self
        }
    }
}
