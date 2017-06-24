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
        
        let description = NSPersistentStoreDescription()
        
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Traver.sqlite")
        
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in } )
        return container
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    func saveContext () {
        try? mainContext.save()
    }

}
