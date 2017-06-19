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
    @IBOutlet weak var imageViewIcon: UIImageView!

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        imageViewPhoto.layer.cornerRadius = imageViewPhoto.frame.height / 2
        imageViewIcon.layer.cornerRadius = 10
        
        let image = SVGKImage(named: "WorldMap.svg")!
        let width = self.bounds.width
        let scale = width / image.size.width
        let height = image.size.height * scale
        image.size = CGSize(width: width, height: height)
        if let imageView = SVGKLayeredImageView(svgkImage: image) {
            viewMap.addSubview(imageView)
            image.colorVisitedCounties(for: User.shared)
        }
        
        imageViewPhoto.image = User.shared.photo
        labelName.text = User.shared.name
        labelCountriesVisited.text = "%d/180 countries visited".localized(for: User.shared.visitedCountries.count)
    }
}
