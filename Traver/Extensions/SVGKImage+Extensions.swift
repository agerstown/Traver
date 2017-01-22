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
        //let visitedCountriesLayers = countriesLayers.filter { User.sharedInstance.visitedCountriesCodes.contains($0.name!) }
        let visitedCountriesLayers = countriesLayers.filter { (layer) in
            User.sharedInstance.visitedCountries.contains(where: { $0.code == layer.name! })
        }
        
        for layer in visitedCountriesLayers {
            let color = UIColor.blue
            layer.fillColor = color.cgColor
        }
    }
    
}
