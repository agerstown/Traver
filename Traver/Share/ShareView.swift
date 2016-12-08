//
//  ShareView.swift
//  Traver
//
//  Created by Natalia Nikitina on 12/8/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class ShareView: UIView {
    
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCountriesVisited: UILabel!

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        imageViewPhoto.layer.cornerRadius = imageViewPhoto.frame.height / 2
        labelName.adjustsFontSizeToFitWidth = true
        labelCountriesVisited.adjustsFontSizeToFitWidth = true
    }
}
