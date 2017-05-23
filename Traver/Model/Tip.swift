//
//  Tip.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/20/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class Tip {
    
//    var authorName: String
//    var authorPhoto: UIImage
    var author: TipAuthor
    var country: Codes.Country
    var title: String
    var text: String
    var creationDate: Date
    
    init(author: TipAuthor, country: Codes.Country, title: String, text: String, creationDate: Date) {
        self.author = author
        self.title = title
        self.text = text
        self.country = country
        self.creationDate = creationDate
    }
    
}
