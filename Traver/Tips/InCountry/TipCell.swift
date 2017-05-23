//
//  TipCell.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/20/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class TipCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var imageViewAuthorPhoto: UIImageView!
    @IBOutlet weak var labelAuthorName: UILabel!
    @IBOutlet weak var labelCreationDate: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageViewAuthorPhoto.layer.cornerRadius = imageViewAuthorPhoto.frame.height / 2
    }
}
