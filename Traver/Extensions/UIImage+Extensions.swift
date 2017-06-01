//
//  UIImage+SizeReduction.swift
//  Traver
//
//  Created by Natalia Nikitina on 4/3/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

extension UIImage {
    
    func reduced() -> UIImage? {
        var canvasSize = CGSize()
        let minSize: CGFloat = 200
        if size.width < size.height {
            canvasSize = CGSize(width: minSize, height: CGFloat(ceil(minSize/size.width * size.height)))
        } else {
            canvasSize = CGSize(width: CGFloat(ceil(minSize/size.height * size.width)), height: minSize)
        }
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func normalizedImage() -> UIImage {
        
        if (self.imageOrientation == UIImageOrientation.up) {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
    
}
