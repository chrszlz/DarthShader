//
//  Photos+Additions.swift
//  Shades
//
//  Created by Chris Zelazo on 4/7/19.
//  Copyright © 2019 Chris Zelazo. All rights reserved.
//

import Photos

public extension PHPhotoLibrary {
    
    /// Returns information about your app’s authorization to access
    /// the user’s photo library.
    static var isAuthorized: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    /// Returns true when the user has not denied access or yet been prompted.
    static var canAuthorize: Bool {
        return PHPhotoLibrary.authorizationStatus() == .notDetermined
    }
    
}

