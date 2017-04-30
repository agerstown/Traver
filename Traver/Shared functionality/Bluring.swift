//
//  Bluring.swift
//  Traver
//
//  Created by Natalia Nikitina on 4/30/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class Bluring {
    
    static func blurBackground(backgroundController: UIViewController) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(backgroundController.view.frame.size, false, 0)
        backgroundController.view.drawHierarchy(in: backgroundController.view.frame, afterScreenUpdates: true)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let tintColor = UIColor(white:0.11, alpha:0.75) //0.11 0.8
        return snapshot.applyBlurWithRadius(3, tintColor:tintColor, saturationDeltaFactor:1.8, maskImage:nil)! //5 1.8
    }
    
}
