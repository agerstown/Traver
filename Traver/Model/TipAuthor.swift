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
    var id: String
    
    var name: String?
    var photoPath: String?
    var photo: UIImage?
    var location: String?
    
    init(token: String, id: String) {
        self.token = token
        self.id = id
    }
    
    init(user: User) {
        self.token = user.token!
        self.id = user.id!
        self.name = user.name
        self.photoPath = user.photoPath
        self.photo = user.photo
        self.location = user.location
    }
    
}
