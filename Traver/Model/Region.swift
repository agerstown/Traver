//
//  Region.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/24/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import CoreData

@objc(Region)
class Region: NSManagedObject {
    
    @NSManaged var code: String
    @NSManaged var index: Int
    @NSManaged var visitedCountries: NSOrderedSet?
    
    init(code: String, index: Int) {
        let entity = NSEntityDescription.entity(forEntityName: "Region", in: CoreDataStack.shared.mainContext)!
        super.init(entity: entity, insertInto: CoreDataStack.shared.mainContext)
        self.code = code
        self.index = index
    }

}
