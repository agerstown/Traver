//
//  User.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/22/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class User {
    
    var id: Int
    var name: String?
    var company: String?
    var facebookID: Int?
    var vkID: Int?
    var visitedCountries: [String]
    var friends: [User]?
    
    static let sharedInstance = User(id: 1)
    
    init(id: Int) {
        self.id = id
        self.visitedCountries = [String]()
    }
    
}
