//
//  SceneViewController.swift
//  Shades
//
//  Created by Chris Zelazo on 2/18/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import UIKit
import SceneKit
import ReplayKit

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
    
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.numberOfTouchesRequired = 2
        recognizer.addTarget(self, action: #selector(handleTap(_:)))
        return recognizer
    }()
    
    private lazy var forceRecognizer: ForceTouchGestureRecognizer = {
        let recognizer = ForceTouchGestureRecognizer()
        recognizer.minimumForceActivation = 0.2
        recognizer.addTarget(self, action: #selector(handleForceTouch(_:)))
        return recognizer
    }()
    
    
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
        
        view.addGestureRecognizer(tapRecognizer)
        sceneView?.addGestureRecognizer(forceRecognizer)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let helperFunctions: [Item] = [.code(Snippet("modFunctions", code: .modFunctions)),
                                       .code(Snippet("circle", code: .circle)),
                                       .code(Snippet("snoise", code: .snoise)),
                                       .code(Snippet("testFunctions", code: .testFunctions)),
                                       .code(Snippet("body", code: .pragmaBody))]
        
        codeTable?.sections = [Section("Settings",
                                       items: [.geometry(GeometryModel())],
                                       isCollapsed: true),
//                               Section("Utility",
//                                       items: helperFunctions,
//                                       isCollapsed: true),
//                               Section("Fragment Shader",
//                                       items: [.code(Snippet("Fragment", code: .fragmentShader, isFragmentShader: true))],
//                                       isCollapsed: false)]
            Section("Fragment Shader",
                    items: [.code(Snippet("Fragment", code: .megaTest2, isFragmentShader: true))],
                    isCollapsed: false)]
        codeTable?.tableView.reloadData()
        sceneController?.fragment = codeTable?.shader
    }
    
    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let codeView = codeTable?.view else {
            return
        }
        codeView.isHidden = !codeView.isHidden
        codeView.endEditing(true)
    }
    
    @objc private func handleForceTouch(_ recognizer: ForceTouchGestureRecognizer) {
        switch recognizer.state {
        case .began:
            TapticEngine.impact.feedback(.light)
            
        case .changed:
            let scale = 1.0 - (0.04 * recognizer.force)
            DispatchQueue.main.async {
                self.view.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
            
        default:
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.15) {
                    self.view.transform = .identity
                }
            }
        }
        
        if recognizer.force > 0.99 {
            // Stop the controller from tracking force
            recognizer.state = .ended
            
            TapticEngine.impact.feedback(.medium)
            
            if Recorder.isRecording {
                Recorder.stopRecording { [weak self] previewController, _ in
                    guard let previewController = previewController else {
                        return
                    }
                    previewController.previewControllerDelegate = self
                    self?.present(previewController, animated: true)
                }
            } else {
                Recorder.startRecording()
            }
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneView?.frame = view.bounds
    }
    
}

extension SceneViewController: CodeTableDelegate {
    
    public func codeTable(_ table: CodeTableView, didSelect geometry: Geometry) {
        sceneController?.geometryType = geometry.type
    }
    
    public func codeTable(_ table: CodeTableView, didUpdate shader: Shader) {
        sceneController?.fragment = shader
        
        if let shader: Snippet = table.sections.items.compactMap({ item -> Snippet? in
            switch item {
            case .code(let snippet):
                guard snippet.isFragmentShader else {
                    fallthrough
                }
                return snippet
            default:
                return nil
            }
        }).first {
            Shader.fragmentShader = shader.code
        }
    }
    
}

extension SceneViewController: RPPreviewViewControllerDelegate {
    
    public func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true)
    }
    
}
