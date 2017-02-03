//
//  CountryItemCell.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/22/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class VisitedCountryItemCell: UITableViewCell {
    
    @IBOutlet weak var labelCountryName: UILabel!
    var country: Country?
    
    override func layoutSubviews() {
        labelCountryName.adjustsFontSizeToFitWidth = true
    }
}
