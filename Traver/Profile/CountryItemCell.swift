//
//  CountryItemCell.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/23/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class CountryItemCell: UITableViewCell {
    
    @IBOutlet weak var labelCountryName: UILabel!
    @IBOutlet weak var buttonItemState: UIButton!
    var country: Codes.Country?

    override func layoutSubviews() {
        super.layoutSubviews()
        labelCountryName.adjustsFontSizeToFitWidth = true
    }
    
}
