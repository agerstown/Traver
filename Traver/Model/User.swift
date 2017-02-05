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
    
    static var shared: User = {
        let frUser = NSFetchRequest<User>(entityName: "User")
        let users = try! CoreDataStack.shared.mainContext.fetch(frUser)
        if users.count > 0 {
            let user = users.first!
            let frRegion = NSFetchRequest<Region>(entityName: "Region")
            let visitedRegions = try! CoreDataStack.shared.mainContext.fetch(frRegion)
            user.visitedRegions = visitedRegions.sorted { $0.index < $1.index }
            return user
        } else {
            return User(context: CoreDataStack.shared.persistentContainer.viewContext)
        }
    }()
    
    var token: String?
    @NSManaged var name: String?
    @NSManaged var photoData: Data?
    var photo: UIImage? {
        if let data = photoData {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    @NSManaged var facebookID: String?
    @NSManaged var facebookEmail: String?
    @NSManaged var location: String?
    
    var visitedRegions: [Region] = []
    
    var visitedCountries: [Country] {
        var countries: [Country] = []
        for region in visitedRegions {
            let countriesInRegion = Array(region.visitedCountries) as! [Country]
            countries.append(contentsOf: countriesInRegion)
        }
        return countries
    }
    
    func saveCountryVisits(codes: [String]) -> [Country] {
        var countries: [Country] = []
        for code in codes {
            if let country = saveCountryVisit(code: code) {
                countries.append(country)
            }
        }
        CoreDataStack.shared.saveContext()
        return countries
    }
    
    func removeCountryVisit(country: Country) {
        let region = findRegion(for: country)
        if region.visitedCountries.count == 1 {
            CoreDataStack.shared.mainContext.delete(region)
            User.shared.visitedRegions.removeObject(region)
        } else {
            CoreDataStack.shared.mainContext.delete(country)
            region.sortedVisitedCountries.removeObject(country)
        }
        CoreDataStack.shared.saveContext()
    }
    
    private func saveCountryVisit(code: String) -> Country? {
        let region = findOrCreateRegion(for: code)
        return createCountryIfNeeded(for: code, in: region)
    }
    
    private func createCountryIfNeeded(for code: String, in region: Region) -> Country? {
        var country: Country?
        if !User.shared.visitedCountries.contains(where: { $0.code == code }) {
            country = Country(code: code, region: region)
            if !region.sortedVisitedCountries.contains(country!) {
                region.sortedVisitedCountries.append(country!) { $0.code.localized() < $1.code.localized() }
            }
        }
        return country
    }
    
    private func findOrCreateRegion(for countryCode: String) -> Region {
        let regionObject: Region?
        let region = Codes.countryToRegion[countryCode]!
        if User.shared.visitedRegions.contains(where: { $0.code == region.code }) {
            let visitedRegions = User.shared.visitedRegions
            regionObject = visitedRegions.filter { $0.code == region.code }.first
        } else {
            regionObject = Region(code: region.code, index: Int16(Codes.Region.all.index(of: region)!))
            User.shared.visitedRegions.append(regionObject!) { $0.index < $1.index }
        }
        return regionObject!
    }
    
    private func findRegion(for country: Country) -> Region {
        return User.shared.visitedRegions.filter { $0.visitedCountries.contains(country) }.first!
    }
    
}
