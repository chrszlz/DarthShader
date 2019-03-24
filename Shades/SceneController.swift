//
//  SceneController.swift
//  Shades
//
//  Created by Chris Zelazo on 2/12/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import Foundation
import SceneKit

open class SceneController: SCNScene {
    
    public let node = SCNNode()
    
    weak public private(set) var view: SCNView?
    
    public var geometryType: SCNGeometry.Type? {
        didSet {
            guard let type = geometryType, let fragment = fragment else {
                return
            }
            node.geometry = geometry(of: type)
            updateFragmentShaderModifier(fragment)
        }
    }
    
    public var size: CGSize = .zero {
        didSet {
//            switch node.geometry {
//            case let g as SCNPlane:
//                g.width = size.width
//                g.height = size.height
//
//            default:
//                assertionFailure("Unexpected geometry: \(node.geometry.debugDescription)")
//            }
        }
    }
    
    private var visibleSize: CGSize {
        guard let view = view else {
            return .zero
        }
        
        let aspectRatio: CGFloat = view.bounds.width / view.bounds.height
        let height: CGFloat = 2 * tan(fieldOfView / 2.0) * CGFloat(cameraNode.position.z)
        return CGSize(width: height * aspectRatio, height: height)
    }
    
    public private(set) lazy var cameraNode: SCNNode = {
        let node = SCNNode()
        
        let camera = SCNCamera()
        node.camera = camera
        
        return node
    }()
    
    /// The vertical or horizontal viewing angle of the camera.
    public var fieldOfView: CGFloat {
        guard let camera = cameraNode.camera else {
            return 0.0
        }
        return camera.fieldOfView * .pi / 180.0
    }
    
    /// The fragment shader for `SCNNode.SCNGeometry.firstMaterial`.
    public var fragment: Shader? {
        didSet {
            guard let fragment = fragment else {
                return
            }
            updateFragmentShaderModifier(fragment)
        }
    }

    convenience init(view: SCNView) {
        self.init()
        
        // Retain a weak reference of the view so we can swap geometries.
        // This is not great.
        self.view = view
        
        /// Node
        rootNode.addChildNode(node)
        
        /// Camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        rootNode.addChildNode(cameraNode)

        /// Node Geometry
        size = visibleSize
        node.geometry = geometry(of: SCNPlane.self)

        /// View
        view.allowsCameraControl = true
        
        // Attatch self (SCNNode) to view
        view.scene = self
    }
  
    deinit {
        self.view = nil
    }
    
    // MARK: - Utility
    
    private func updateFragmentShaderModifier(_ shader: Shader) {
        node.geometry?.firstMaterial?.shaderModifiers = [.fragment: shader]
    }
    
    private func geometry<T: SCNGeometry>(of type: T.Type) -> T {
        let minDimension = min(size.width, size.height)
        
        let g: SCNGeometry
        switch type {
        case is SCNPlane.Type:
            g = SCNPlane(width: size.width, height: size.height)
        
        case is SCNBox.Type:
            let dimension = minDimension * 0.8
            g = SCNBox(width: dimension, height: dimension, length: dimension, chamferRadius: 0)
        
        case is SCNPyramid.Type:
            let dimension = minDimension * 0.8
            let height = 0.5 * sqrt(2) * dimension
            g = SCNPyramid(width: dimension, height: height, length: dimension)
            
        case is SCNSphere.Type:
            let radius = minDimension * 0.8 / 2.0
            g = SCNSphere(radius: radius)
            
        case is SCNTorus.Type:
            let ringRadius = minDimension * 0.8 / 2.0
            let pipeRadius = ringRadius / 8.0
            g = SCNTorus(ringRadius: ringRadius, pipeRadius: pipeRadius)
            
        default:
            g = geometry(of: SCNPlane.self)
        }
        
        g.firstMaterial?.isDoubleSided = true
        return g as! T
    }
}
