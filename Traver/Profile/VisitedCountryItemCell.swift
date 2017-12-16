//
//  CountryItemCell.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/22/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

protocol TipRequestDelegate: class {
    func tipRequested(cell: UITableViewCell)
}

class VisitedCountryItemCell: UITableViewCell {
    
    @IBOutlet weak var labelCountryName: UILabel!
    @IBOutlet weak var buttonAskForTip: UIButton!
    @IBOutlet weak var constraintTrailingLabelName: NSLayoutConstraint!
    
    var country: Country?
    
    weak var tipRequestDelegate: TipRequestDelegate?
    
    // MARK: - Actions
    @IBAction func buttonAskForTipTapped(_ sender: Any) {
        tipRequestDelegate?.tipRequested(cell: self)
    }
}
