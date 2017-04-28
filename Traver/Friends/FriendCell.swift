//
//  FriendCell.swift
//  
//
//  Created by Natalia Nikitina on 4/16/17.
//
//

import Foundation

class FriendCell: UITableViewCell {
    
    @IBOutlet weak var imageViewPhoto: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelVisitedCountries: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        labelName.adjustsFontSizeToFitWidth = true
        imageViewPhoto.layer.cornerRadius = imageViewPhoto.frame.height / 2
    }
    
}
