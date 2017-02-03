//
//  User.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/22/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import CoreData

@objc(User)
class User: NSManagedObject {
    
    static var sharedInstance: User {
        do {
            let result = try CoreDataStack.sharedInstance.persistentContainer.viewContext.fetch(fetchUsersRequest)
            if result.count > 0 {
                return result.first
            } else {
                return User(context: CoreDataStack.sharedInstance.persistentContainer.viewContext)
            }
        } catch {
            return User(context: CoreDataStack.sharedInstance.persistentContainer.viewContext)
        }
    }
    
    var token: String?
    @NSManaged var name: String?
    var photo: UIImage?
    @NSManaged var facebookID: String?
    @NSManaged var facebookEmail: String?
    @NSManaged var location: String?
    
    var visitedRegions = [Region]()
    
    var visitedCountries: [Country] {
        var countries = [Country]()
        for region in visitedRegions {
            countries.append(contentsOf: region.visitedCountries)
        }
        return countries
    }
    
    static let fetchUsersRequest = NSFetchRequest<User>(entityName: "User")
    
    func saveCountryVisit(code: String) -> Country? {
        let region = findOrCreateRegion(for: code)
        return createCountryIfNeeded(for: code, in: region)
    }
    
    func removeCountryVisit(country: Country) {
        let region = findRegion(for: country)
        region.visitedCountries.removeObject(country)
        if region.visitedCountries.isEmpty {
            User.sharedInstance.visitedRegions.removeObject(region)
        }
    }
    
    private func createCountryIfNeeded(for code: String, in region: Region) -> Country? {
        var country: Country?
        if !User.sharedInstance.visitedCountries.contains(where: { $0.code == code }) {
            country = Country(code: code, region: region)
            region.visitedCountries.append(country!) { $0.code.localized() < $1.code.localized() }
        }
        return country
    }
    
    private func findOrCreateRegion(for countryCode: String) -> Region {
        let regionObject: Region?
        let region = Codes.countryToRegion[countryCode]!
        if User.sharedInstance.visitedRegions.contains(where: { $0.code == region.code }) {
            let visitedRegions = User.sharedInstance.visitedRegions
            regionObject = visitedRegions.filter { $0.code == region.code }.first
        } else {
            regionObject = Region(code: region.code, index: Codes.Region.all.index(of: region)!)
            User.sharedInstance.visitedRegions.append(regionObject!) { $0.index < $1.index }
        }
        return regionObject!
    }
    
    private func findRegion(for country: Country) -> Region {
        return User.sharedInstance.visitedRegions.filter { $0.visitedCountries.contains(country) }.first!
    }
    
}
