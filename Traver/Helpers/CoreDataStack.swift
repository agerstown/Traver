//
//  CoreDataStack.swift
//  Traver
//
//  Created by Natalia Nikitina on 1/20/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Traver")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in } )
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext () {
        try? mainContext.save()
    }

}
