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
        let fr = NSFetchRequest<User>(entityName: "User")
        let result = try! CoreDataStack.shared.mainContext.fetch(fr)
        if result.count > 0 {
            return result.first!
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
            countries.append(contentsOf: region.visitedCountries)
        }
        return countries
    }
    
    func saveCountryVisit(code: String) -> Country? {
        let region = findOrCreateRegion(for: code)
        return createCountryIfNeeded(for: code, in: region)
    }
    
    func removeCountryVisit(country: Country) {
        let region = findRegion(for: country)
        region.visitedCountries.removeObject(country)
        if region.visitedCountries.isEmpty {
            User.shared.visitedRegions.removeObject(region)
        }
    }
    
    private func createCountryIfNeeded(for code: String, in region: Region) -> Country? {
        var country: Country?
        if !User.shared.visitedCountries.contains(where: { $0.code == code }) {
            country = Country(code: code, region: region)
            region.visitedCountries.append(country!) { $0.code.localized() < $1.code.localized() }
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
            regionObject = Region(code: region.code, index: Codes.Region.all.index(of: region)!)
            User.shared.visitedRegions.append(regionObject!) { $0.index < $1.index }
        }
        return regionObject!
    }
    
    private func findRegion(for country: Country) -> Region {
        return User.shared.visitedRegions.filter { $0.visitedCountries.contains(country) }.first!
    }
    
}
