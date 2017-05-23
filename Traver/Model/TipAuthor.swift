//
//  TipAuthor.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/23/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class TipAuthor {
    
    var username: String
    var token: String
    
    var name: String?
    var photoPath: String?
    var photo: UIImage?
    var location: String?
    
    init(username: String, token: String) {
        self.username = username
        self.token = token
    }
    
}
