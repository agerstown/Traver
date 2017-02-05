//
//  Country.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/22/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import CoreData

@objc(Country)
class Country: NSObject {
    
    @NSManaged var code: String
    @NSManaged var region: Region

    init(code: String, region: Region) {
        let entity = NSEntityDescription.entity(forEntityName: "Region", in: CoreDataStack.shared.mainContext)!
        super.init(entity: entity, insertInto: CoreDataStack.shared.mainContext)
        self.code = code
        self.region = region
    }
}
