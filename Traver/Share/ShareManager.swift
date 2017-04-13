//
//  ShareManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 12/8/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class ShareManager: NSObject {
    
    static let shared = ShareManager()
    
    func getSharePicture() -> UIImage? {
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
        
        shareView.labelCountriesVisited.text = "%d countries visited".localized(for: User.shared.visitedCountries.count)
        
        UIGraphicsBeginImageContext(shareView.bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            shareView.layer.render(in: context)
            if let picture = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                return picture
            }
        }
        
        return nil
    }
    
    func shareProfile(picture: UIImage, controller: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [picture], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            controller.dismiss(animated: true, completion: nil)
        }
        // activityViewController.popoverPresentationController?.sourceView = controller.view // so that iPads won't crash
        controller.present(activityViewController, animated: true, completion: nil)
    }
    
}
