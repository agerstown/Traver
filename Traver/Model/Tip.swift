//
//  Tip.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/20/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class Tip: NSObject {

    var id: Int
    var author: TipAuthor
    var country: Codes.Country
    var title: String
    var text: String
    var updateDate: Date
    var dateString: String {
        return dateFormatter.string(from: updateDate)
    }
    
    let dateFormatter = DateFormatter()
    
    init(id: Int, author: TipAuthor, country: Codes.Country, title: String, text: String, updateDate: Date) {
        self.id = id
        self.author = author
        self.title = title
        self.text = text
        self.country = country
        self.updateDate = updateDate
        
        dateFormatter.dateFormat = "dd.MM.yyyy"
    }
    
}
