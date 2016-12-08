//
//  PhotosAccessManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 12/8/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class PhotosAccessManager {
    
    static let sharedInstance = PhotosAccessManager()
    
    func showAlertAllowAccessToPhotos(on controller: UIViewController, withTitle title: String) {
        let alert = UIAlertController(title: title.localized(), message: "Please allow \"Traver\" to access Photos".localized(), preferredStyle: UIAlertControllerStyle.alert)
        let settingsAction = UIAlertAction(title: "Go to Settings".localized(), style: .default) { (action) in
            DispatchQueue.main.async {
                if let appSettingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(appSettingsURL)
                }
            }
        }
        let dontAllowAction = UIAlertAction(title: "Don't Allow".localized(), style: .cancel)
        alert.addAction(dontAllowAction)
        alert.addAction(settingsAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    func showAlertRestrictedAccess(on controller: UIViewController, withMessage message: String) {
        let alert = UIAlertController(title: "Access to Photos is restricted".localized(), message: message.localized(), preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK".localized(), style: .cancel)
        alert.addAction(OKAction)
        controller.present(alert, animated: true, completion: nil)
    }
}
