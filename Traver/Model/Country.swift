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
class Country: NSManagedObject {
    
    @NSManaged var code: String
    @NSManaged var name: String
    @NSManaged var region: Region
    @NSManaged var users: NSSet

    convenience init(code: String, region: Region) {
        let entity = NSEntityDescription.entity(forEntityName: "Country", in: CoreDataStack.shared.mainContext)!
        self.init(entity: entity, insertInto: CoreDataStack.shared.mainContext)
        self.code = code
        self.name = code.localized()
        self.region = region
    }
}
