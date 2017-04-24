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
            
            //let frRegion = NSFetchRequest<Region>(entityName: "Region")
            //let visitedRegions = try! CoreDataStack.shared.mainContext.fetch(frRegion)
            //user.visitedRegions = visitedRegions.sorted { $0.index < $1.index }

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
    
    @NSManaged var friends: NSMutableSet
//    @NSManaged var visitedCountries: NSMutableSet
    @NSManaged var visitedCountries: NSSet
    
    var username: String {
        return facebookID != nil ? "fb" + facebookID! : iCloudID != nil ? "ic" + iCloudID! : ""
    }
    
    var visitedCountriesArray: [Country] {
        return visitedCountries.allObjects as! [Country]
    }
    
    
    
//    var visitedRegions: [Region] = []
//    
//    var visitedCountries: [Country] {
//        var countries: [Country] = []
//        for region in visitedRegions {
//            let countriesInRegion = Array(region.visitedCountries) as! [Country]
//            countries.append(contentsOf: countriesInRegion)
//        }
//        return countries
//    }
    
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
        
//        let currentCountryVisits = User.shared.visitedCountries
//
//        for country in currentCountryVisits {
//            if !codes.contains(country.code) {
//                removeCountryVisit(country: country)
//            }
//        }
//
//        for code in codes {
//            saveCountryVisit(code: code)
//        }
//        
//        CoreDataStack.shared.saveContext()
    }
    
    func addCountryVisit(code: String) {
        saveCountryVisit(code: code)
        CoreDataStack.shared.saveContext()
    }
    
    func removeCountryVisit(country: Country) {
//        
        //self.visitedCountries.remove(country)
        
        let allVisitedCountries = NSMutableSet(set: self.visitedCountries)
        allVisitedCountries.remove(country)
        self.visitedCountries = allVisitedCountries
        
        CoreDataStack.shared.saveContext()
        
//        let region = findRegion(for: country)
//        if region.visitedCountries.count == 1 {
//            CoreDataStack.shared.mainContext.delete(region)
//            User.shared.visitedRegions.removeObject(region)
//        } else {
//            CoreDataStack.shared.mainContext.delete(country)
//            region.sortedVisitedCountries.removeObject(country)
//        }
//        CoreDataStack.shared.saveContext()
    }
    
    
//    func updateInfo() {
//        CoreDataStack.shared.saveContext()
//    }
    
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
        //self.visitedCountries = self.visitedCountries.adding(country!) as NSSet //add(country!)
        let allVisitedCountries = NSMutableSet(set: self.visitedCountries)
        allVisitedCountries.add(country!)
        self.visitedCountries = allVisitedCountries
        
        //country!.region = region
//        
        //self.visitedCountries.add(country!)
//        
        CoreDataStack.shared.saveContext()
        
        //print(country!.users.allObjects)
        
//        if !User.shared.visitedCountries.contains(where: { $0.code == code }) {
//            let country = Country(code: code, region: region)
//            if !region.sortedVisitedCountries.contains(country) {
//                region.sortedVisitedCountries.append(country) { $0.code.localized() < $1.code.localized() }
//            }
//        }
    }
    
    private func findOrCreateRegion(for countryCode: String) -> Region {
//        let regionObject: Region?
        let region = Codes.countryToRegion[countryCode]!
        
        let frRegions = NSFetchRequest<Region>(entityName: "Region")
        let existingRegions = try! CoreDataStack.shared.mainContext.fetch(frRegions)
        
        if existingRegions.contains(where: { $0.code == region.code }) {
            return existingRegions.filter { $0.code == region.code }.first!
        } else {
            return Region(code: region.code, index: Int16(Codes.Region.all.index(of: region)!))
        }
        
//        if User.shared.visitedRegions.contains(where: { $0.code == region.code }) {
//            let visitedRegions = User.shared.visitedRegions
//            regionObject = visitedRegions.filter { $0.code == region.code }.first
//        } else {
//            regionObject = Region(code: region.code, index: Int16(Codes.Region.all.index(of: region)!))
//            User.shared.visitedRegions.append(regionObject!) { $0.index < $1.index }
//        }
//        return regionObject!
    }
    
//    private func findRegion(for country: Country) -> Region {
//        return User.shared.visitedRegions.filter { $0.visitedCountries.contains(country) }.first!
//    }
//    
}
