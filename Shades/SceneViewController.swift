//
//  SceneViewController.swift
//  Shades
//
//  Created by Chris Zelazo on 2/18/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit
import SceneKit

/// SceneViewController
///
/// UIViewController subclass with a SCNView
open class SceneViewController: UIViewController {
    
    public var codeTable: CodeTableView?
    
    private var beganForceTouch: Bool = false
    
    open override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /// The SCNView for this view controller. Added to the top of the underlying
    /// UIViewController's subview stack when set.
    public var sceneView: SCNView? {
        didSet {
            guard let sceneView = sceneView, !view.subviews.contains(sceneView) else {
                return
            }
            sceneController = SceneController(view: sceneView)
            view.addSubview(sceneView)
        }
    }
    
    /// `SCNNode`, `SCNGeometry` and shaders which control the local variable `sceneView`.
    public private(set) var sceneController: SceneController?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup initial SCNView
        sceneView = SCNView(frame: view.bounds)
        sceneView?.rendersContinuously = true
        
        // Setup code table
        codeTable = CodeTableView(style: .plain)
        codeTable?.delegate = self
        addChild(codeTable!)
        view.addSubview(codeTable!.view)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let helpers = CodeSection(name: "Utility",
                                  items: [Snippet("modFunctions", code: .modFunctions),
                                          Snippet("circle", code: .circle),
                                          Snippet("snoise", code: .snoise),
                                          Snippet("body", code: .pragmaBody)],
                                  isCollapsed: true)

        let fragment = CodeSection(name: "Fragment shader",
                                  items: [Snippet("Fragment", code: Shader.fragmentShader)],
                                  isCollapsed: false,
                                  isFragment: true)
        
        codeTable?.sections = [helpers, fragment]
        codeTable?.tableView.reloadData()
        sceneController?.fragment = codeTable?.shader
    }
    
}

extension SceneViewController: CodeTableDelegate {
    
    public func codeTable(_ table: CodeTableView, didUpdate shader: Shader) {
        sceneController?.fragment = shader

        // Fuck this is bad
        if let updatedFragmentShader = table.sections.first(where: { $0.isFragment })?.items.first?.code {
            Shader.fragmentShader = updatedFragmentShader
        }
    }

    // MARK: - Gesture Handling

    /*
    
    public func codeTableTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let force = touches.first?.normalizedForce, force > 0.3 else {
            return
        }
        
        beganForceTouch = true
    }
    
    public func codeTableTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let force = touches.first?.normalizedForce, force > 0.3 && beganForceTouch, let codeTable = codeTable else {
            return
        }
        
        var scale = force.lerp(bounds: (0.3, 1.0), outputBounds: (0.0, 1.0))
        if !codeTable.view.isHidden {
            scale = 1.0 - scale
        }
        codeTable.view.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    public func codeTableTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        beganForceTouch = false
    }
    
    public func codeTableTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        beganForceTouch = false
    }
 
 */
}
