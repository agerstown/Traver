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
//    @NSManaged var visitedCountries: NSOrderedSet
    @NSManaged var countries: NSSet
    
//    lazy var sortedVisitedCountries: [Country] = {
//        let array = Array(self.visitedCountries) as! [Country]
//        return array.sorted { $0.code.localized() < $1.code.localized() }
//    }()
    
    lazy var sortedVisitedCountries: [Country] = {
        let array = Array(self.countries) as! [Country]
        return array.sorted { $0.code.localized() < $1.code.localized() }
    }()
    
    convenience init(code: String, index: Int16) {
        let entity = NSEntityDescription.entity(forEntityName: "Region", in: CoreDataStack.shared.mainContext)!
        self.init(entity: entity, insertInto: CoreDataStack.shared.mainContext)
        self.code = code
        self.index = index
    }

}
