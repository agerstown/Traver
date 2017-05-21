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
    @IBOutlet weak var constraintLabelName: NSLayoutConstraint!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelVisitedCountries: UILabel!
    @IBOutlet weak var labelCurrentLocation: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageViewPhoto.layer.cornerRadius = imageViewPhoto.frame.height / 2
    }
    
}
