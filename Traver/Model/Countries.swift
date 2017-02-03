//
//  Countries.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/22/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class Country: NSObject {
    
    var code: String
    var region: Region
    
    init(code: String, region: Region) {
        self.code = code
        self.region = region
    }
}
