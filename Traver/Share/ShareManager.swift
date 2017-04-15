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
        let activityViewController = UIActivityViewController(activityItems: [picture], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            controller.dismiss(animated: true, completion: nil)
        }
        // activityViewController.popoverPresentationController?.sourceView = controller.view // so that iPads won't crash
        controller.present(activityViewController, animated: true, completion: nil)
    }
    
}
