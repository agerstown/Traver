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

            if user.locale != nil && user.locale != Locale.current.languageCode {
                let frCountries = NSFetchRequest<Country>(entityName: "Country")
                let countries = try! CoreDataStack.shared.mainContext.fetch(frCountries)
                for country in countries {
                    country.name = country.code.localized()
                }
                CoreDataStack.shared.saveContext()
            }
            
            user.locale = Locale.current.languageCode
            
            if let token = user.token {
                UserApiManager.shared.getUserInfo(user: user) { success in
                    if success && user.iCloudID == nil {
                        CloudKitHelper.shared.login(user: user)
                    }
                }
            } else {
                CloudKitHelper.shared.login(user: user)
            }
            
            return user
        } else {
            let user = User(context: CoreDataStack.shared.mainContext)
            user.locale = Locale.current.languageCode
            CloudKitHelper.shared.login(user: user)
            return user
        }
    }()
    
    @NSManaged var token: String?
    @NSManaged var name: String?
    @NSManaged var photoData: Data?
    var photo: UIImage? {
        if let data = self.photoData {
            return UIImage(data: data)
        } else {
            return nil
        }
    }
    @NSManaged var photoPath: String?
    @NSManaged var facebookID: String?
    @NSManaged var facebookEmail: String?
    @NSManaged var location: String?
    @NSManaged var iCloudID: String?
    @NSManaged var locale: String?
    @NSManaged var numberOfVisitedCountries: String?
    @NSManaged var feedbackEmail: String?
    @NSManaged var currentCountryCode: String?
    @NSManaged var currentRegion: String?
    var currentLocation: String? {
        if let currentCountryCode = currentCountryCode {
            var location = currentCountryCode.localized()
            if let region = currentRegion {
                location += ", " + region
            }
            return location
        }
        return nil
    }
    
    @NSManaged var friends: NSOrderedSet
    @NSManaged var visitedCountries: NSSet
    
    var username: String {
        return facebookID != nil ? "fb" + facebookID! : iCloudID != nil ? "ic" + iCloudID! : ""
    }
    
    var visitedCountriesArray: [Country] {
        return visitedCountries.allObjects as! [Country]
    }
    
    // MARK: - Notifications
    let CountriesUpdatedNotification = NSNotification.Name(rawValue: "CountriesUpdatedNotification")
    
    // MARK: - CoreData
    func updateCountryVisits(codes: [String]) {
        
        let currentCountryVisits = self.visitedCountries.allObjects as! [Country]
        
        for country in currentCountryVisits {
            if !codes.contains(country.code) {
                removeCountryVisit(country: country)
            }
        }
        
        for code in codes {
            saveCountryVisit(code: code)
        }
        
        CoreDataStack.shared.saveContext()
        
        NotificationCenter.default.post(name: self.CountriesUpdatedNotification, object: nil)
    }
    
    func addCountryVisit(code: String) {
        saveCountryVisit(code: code)
        CoreDataStack.shared.saveContext()
    }
    
    func removeCountryVisit(country: Country) {
        let allVisitedCountries = NSMutableSet(set: self.visitedCountries)
        allVisitedCountries.remove(country)
        self.visitedCountries = allVisitedCountries
        
        CoreDataStack.shared.saveContext()
    }
    
    private func saveCountryVisit(code: String) {
        let region = findOrCreateRegion(for: code)
        saveCountry(for: code, in: region)
    }
    
    private func saveCountry(for code: String, in region: Region) {
        let frCountries = NSFetchRequest<Country>(entityName: "Country")
        let existingCountries = try! CoreDataStack.shared.mainContext.fetch(frCountries)
        
        var country: Country?
        
        if !existingCountries.contains(where: { $0.code == code }) {
            country = Country(code: code, region: region)
        } else {
            country = existingCountries.filter { $0.code == code }.first!
        }

        let allVisitedCountries = NSMutableSet(set: self.visitedCountries)
        allVisitedCountries.add(country!)
        self.visitedCountries = allVisitedCountries
        
        CoreDataStack.shared.saveContext()
    }
    
    private func findOrCreateRegion(for countryCode: String) -> Region {
        let region = Codes.countryToRegion[countryCode]!
        
        let frRegions = NSFetchRequest<Region>(entityName: "Region")
        let existingRegions = try! CoreDataStack.shared.mainContext.fetch(frRegions)
        
        if existingRegions.contains(where: { $0.code == region.code }) {
            return existingRegions.filter { $0.code == region.code }.first!
        } else {
            return Region(code: region.code, index: Int16(Codes.Region.all.index(of: region)!))
        }
    }
}
