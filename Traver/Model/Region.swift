//
//  Regions.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/24/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class Region: NSObject {
    
    var code: String
    var index: Int
    var visitedCountries = [Country]()
    
    init(code: String, index: Int) {
        self.code = code
        self.index = index
    }

}
