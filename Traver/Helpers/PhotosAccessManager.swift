//
//  PhotosAccessManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 12/8/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import Photos
import CWStatusBarNotification

class PhotosAccessManager {
    
    static let shared = PhotosAccessManager()
    
    func importVisitedCountries(controller: UIViewController) {
        switch (PHPhotoLibrary.authorizationStatus()) {
        case .authorized:
            VisitedCountriesImporter.shared.fetchVisitedCountriesCodesFromPhotos()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                if status ==  .authorized {
                    VisitedCountriesImporter.shared.fetchVisitedCountriesCodesFromPhotos()
                } else {
                    PhotosAccessManager.shared.showAlertAllowAccessToPhotos(on: controller, withTitle: "Import is impossible".localized())
                }
            })
        case .denied:
            PhotosAccessManager.shared.showAlertAllowAccessToPhotos(on: controller, withTitle: "Import is impossible".localized())
        case .restricted:
            PhotosAccessManager.shared.showAlertRestrictedAccess(on: controller, withMessage: "We can't import visited countries from your Photos as parental controls restrict your ability to grant Photo Library access to apps. Ask the owner to allow it.".localized())
        }
    }
    
    private func showAlertAllowAccessToPhotos(on controller: UIViewController, withTitle title: String) {
        let alert = UIAlertController(title: title.localized(), message: "Please allow \"Traver\" to access Photos".localized(), preferredStyle: UIAlertControllerStyle.alert)
        let settingsAction = UIAlertAction(title: "Go to Settings".localized(), style: .default) { (action) in
            DispatchQueue.main.async {
                if let appSettingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
                }
            }
        }
        let dontAllowAction = UIAlertAction(title: "Don't Allow".localized(), style: .cancel)
        alert.addAction(dontAllowAction)
        alert.addAction(settingsAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
    private func showAlertRestrictedAccess(on controller: UIViewController, withMessage message: String) {
        let alert = UIAlertController(title: "Access to Photos is restricted".localized(), message: message.localized(), preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "OK".localized(), style: .cancel)
        alert.addAction(OKAction)
        controller.present(alert, animated: true, completion: nil)
    }
    
}

