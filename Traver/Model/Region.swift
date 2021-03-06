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
    @NSManaged var index: Int16
    @NSManaged var countries: NSSet
    
    lazy var sortedVisitedCountries: [Country] = {
        let array = Array(self.countries) as! [Country]
        return array.sorted { $0.name < $1.name }
    }()
    
    convenience init(code: String, index: Int16) {
        let entity = NSEntityDescription.entity(forEntityName: "Region", in: CoreDataStack.shared.mainContext)!
        self.init(entity: entity, insertInto: CoreDataStack.shared.mainContext)
        self.code = code
        self.index = index
    }

}
