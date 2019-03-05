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
    
    public private(set) var node: SCNNode?
    
    public var size: CGSize = .zero {
        didSet {
            switch node?.geometry {
            case let g as SCNPlane:
                g.width = size.width
                g.height = size.height

            default:
                assertionFailure("Unexpected geometry: \(node?.geometry.debugDescription ?? "<>")")
            }
        }
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
            node?.geometry?.firstMaterial?.shaderModifiers = [.fragment: fragment]
        }
    }

    convenience init(view: SCNView) {
        self.init()
        
        /// Node
        node = SCNNode()
        guard let node = node else {
            assertionFailure("\(String(describing: self)) Error - Failed to initialize SCNNode.")
            return
        }
        rootNode.addChildNode(node)
        
        /// Camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        rootNode.addChildNode(cameraNode)

        /// Node Geometry
        
        // Calculate size of view given position of camera
        let aspectRatio: CGFloat = view.bounds.width / view.bounds.height
        let visibleHeight: CGFloat = 2 * tan(fieldOfView / 2.0) * CGFloat(cameraNode.position.z)
        let visibleWidth: CGFloat = visibleHeight * aspectRatio
        
        // Create geometry of the given size and add to SCNNode
        let geometry = SCNPlane(width: visibleWidth, height: visibleHeight)
        size = CGSize(width: geometry.width, height: geometry.height)
        geometry.firstMaterial?.isDoubleSided = true
        node.geometry = geometry
        
        /// Shaders
//        setupFragmentShader()

        /// View
        view.allowsCameraControl = true
        
        // Attatch self (SCNNode) to view
        view.scene = self
    }
    
    private func setupFragmentShader() {
        fragment =
        """
        vec2 st = _surface.position.xy / u_boundingBox[1].xy;
        float brightness = 0.9;
        
        vec3 color = vec3(
        circle(st, snoise(st + u_time*0.15) *0.1 ) * brightness,
        circle(st, -snoise(st + u_time*0.025) *0.1 ) * brightness,
        circle(st, snoise(st + -1.*u_time*0.3) *0.15 ) * brightness);
        
        _output.color = vec4(color, 1.0);
        """
    }
    
}
