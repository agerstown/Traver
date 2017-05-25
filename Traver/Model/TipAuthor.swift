//
//  TipAuthor.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/23/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class TipAuthor {
    
    var token: String
    
    var name: String?
    var photoPath: String?
    var photo: UIImage?
    var location: String?
    
    init(token: String) {
        self.token = token
    }
    
    init(user: User) {
        self.token = user.token!
        self.name = user.name
        self.photoPath = user.photoPath
        self.photo = user.photo
        self.location = user.location
    }
    
}
