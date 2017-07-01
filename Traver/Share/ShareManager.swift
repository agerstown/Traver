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
        let imageItem = ImageProvider(image: picture)
        let textItem = TextProvider(text: "My travel map".localized() + " via Traver - appsto.re/ru/tlslkb.i")
        let activityViewController = UIActivityViewController(activityItems: [imageItem, textItem], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            controller.dismiss(animated: true, completion: nil)
        }
        controller.present(activityViewController, animated: true, completion: nil)
    }

}

class TextProvider: NSObject, UIActivityItemSource {
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        return text
    }
}

class ImageProvider: NSObject, UIActivityItemSource {
    var image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        return image
    }
}
