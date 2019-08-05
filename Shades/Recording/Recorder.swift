//
//  Recorder.swift
//  Shades
//
//  Created by Chris Zelazo on 4/7/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import ReplayKit

public protocol RecorderDelegate {
    
}

public final class Recorder: RPScreenRecorder {
    
    public static let sharedIndicatorWindow = RecordWindow()
    
    /// A Boolean value that indicates whether the app is currently recording.
    public class var isRecording: Bool {
        return shared().isRecording
    }

    /// Starts app recording with a completion handler. Note that before recording
    /// actually starts, the user may be prompted with UI to confirm recording.
    public class func startRecording(handler: ((Error?) -> Void)? = nil) {
        // Hacky use of RPScreenRecorder.shared as delegate to stop recording.
        sharedIndicatorWindow.show(delegate: shared())
        
        shared().startRecording { error in
            if let error = error {
                print("[Recorder] Failed to start screen recording. \(error)")
            }
            handler?(error)
        }
    }
    
    /// Stops app recording with a completion handler.
    public class func stopRecording(handler: ((RPPreviewViewController?, Error?) -> Void)? = nil) {
        sharedIndicatorWindow.hide()
        
        shared().stopRecording { previewController, error in
            if let error = error {
                print("[Recorder] Failed to stop screen recording. \(error)")
            }
            handler?(previewController, error)
        }
    }
}

extension RPScreenRecorder: RecordWindowDelegate {
    
    // Hacky use of RPScreenRecorder.shared as delegate to stop recording.
    public func didRequestStopRecording() {
        Recorder.stopRecording()
    }
    
}

public protocol RecordWindowDelegate {
    func didRequestStopRecording()
}

public class RecordWindow: UIWindow {
    
    public var delegate: RecordWindowDelegate?
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.red.withAlphaComponent(0.85)
        button.addTarget(self, action: #selector(handleStopRecording), for: .touchUpInside)
        return button
    }()
    
    convenience init() {
        self.init(frame: CGRect(origin: .zero, size: CGSize(width: 375, height: 40)))

        addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.topAnchor.constraint(equalTo: topAnchor)])
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func show(delegate: RecordWindowDelegate) {
        self.delegate = delegate
        
        windowLevel = .alert
        makeKeyAndVisible()
        
        setWindowHidden(false)
    }
    
    public func hide() {
        delegate = nil
        setWindowHidden(true)
    }
    
    private func setWindowHidden(_ hidden: Bool) {
        let transform: CGAffineTransform = hidden ? CGAffineTransform(translationX: 0, y: -bounds.height) : .identity
        let initialVelocity: CGVector = .zero//hidden ? .zero : CGVector(dx: 0, dy: 15.0)
        let animator = UIViewPropertyAnimator(damping: 0.95, response: 0.25, initialVelocity: initialVelocity) {
            self.transform = transform
        }
        animator.addCompletion { _ in
            self.isHidden = hidden
        }
        animator.startAnimation()
    }
    
    @objc private func handleStopRecording() {
        delegate?.didRequestStopRecording()
    }
    
    deinit {
        delegate = nil
    }
    
}
