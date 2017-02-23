//
//  SVGKImage+Extensions.swift
//  Traver
//
//  Created by Natalia Nikitina on 12/9/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

extension SVGKImage {
    
    func colorVisitedCounties() {
        let countriesLayers = self.caLayerTree.sublayers?[0].sublayers as! [CAShapeLayer]
        
        for layer in countriesLayers {
            layer.fillColor = UIColor.countryDefaultColor.cgColor
        }
        
        let visitedCountriesLayers = countriesLayers.filter { (layer) in
            User.shared.visitedCountries.contains(where: { $0.code == layer.name! })
        }
        
        for layer in visitedCountriesLayers {
            let color = UIColor.blue
            layer.fillColor = color.cgColor
        }
    }
    
}
