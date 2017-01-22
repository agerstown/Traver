//
//  ShareManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 12/8/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class ShareManager: NSObject {
    
    static let sharedInstance = ShareManager()
    
    func saveProfileSharePicture() {
        let shareView = Bundle.main.loadNibNamed("Share", owner: nil, options: nil)![0] as! ShareView
        
        let image = SVGKImage(named: "WorldMap.svg")!
        let width = shareView.bounds.width
        let scale = width / image.size.width
        let height = image.size.height * scale
        image.size = CGSize(width: width, height: height)
        if let imageView = SVGKLayeredImageView(svgkImage: image) {
            shareView.viewMap.addSubview(imageView)
            image.colorVisitedCounties()
        }
        
        //shareView.labelCountriesVisited.text = "%d countries visited".localized(for: User.sharedInstance.visitedCountriesCodes.count)
        shareView.labelCountriesVisited.text = "%d countries visited".localized(for: User.sharedInstance.visitedCountries.count)
        
        UIGraphicsBeginImageContext(shareView.bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            shareView.layer.render(in: context)
            if let screenShot = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                UIImageWriteToSavedPhotosAlbum(screenShot, self, #selector(shareSavingCompleted(image:error:contextInfo:)), nil)
            }
        }
    }
    
    @objc private func shareSavingCompleted(image: UIImage, error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showSimpleAlert(withTitle: "Error", withMessage: error.localizedDescription)
        } else {
            showSimpleAlert(withTitle: "Success", withMessage: "A picture with your Profile has been saved to Photos.")
        }
    }
    
    private func showSimpleAlert(withTitle title: String, withMessage message: String) {
        let alert = UIAlertController(title: title.localized(), message: message.localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
}
