//
//  User.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/22/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import CoreData
//import SwiftKeychainWrapper

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
            
            //user.token = KeychainWrapper.standard.string(forKey: "token")
            if let token = user.token {
                UserApiManager.shared.getUserInfo(user: user) {
                    if user.iCloudID == nil {
                        CloudKitHelper.shared.login()
                    }
                }
            } else {
                CloudKitHelper.shared.login()
            }
            
            return user
        } else {
            CloudKitHelper.shared.login()
            return User(context: CoreDataStack.shared.mainContext)
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
    
    var visitedRegions: [Region] = []
    
    var visitedCountries: [Country] {
        var countries: [Country] = []
        for region in visitedRegions {
            let countriesInRegion = Array(region.visitedCountries) as! [Country]
            countries.append(contentsOf: countriesInRegion)
        }
        return countries
    }
    
    func updateCountryVisits(codes: [String]) {
        let currentCountryVisits = User.shared.visitedCountries

        for country in currentCountryVisits {
            if !codes.contains(country.code) {
                removeCountryVisit(country: country)
            }
        }
        
        for code in codes {
            saveCountryVisit(code: code)
        }
        
        CoreDataStack.shared.saveContext()
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
    
    func disconnectFacebook() {
        User.shared.facebookID = nil
        User.shared.facebookEmail = nil
        CoreDataStack.shared.saveContext()
    }
    
    func updateInfo() {
        CoreDataStack.shared.saveContext()
    }
    
    private func saveCountryVisit(code: String) {
        let region = findOrCreateRegion(for: code)
        createCountryIfNeeded(for: code, in: region)
    }
    
    private func createCountryIfNeeded(for code: String, in region: Region) {
        if !User.shared.visitedCountries.contains(where: { $0.code == code }) {
            let country = Country(code: code, region: region)
            if !region.sortedVisitedCountries.contains(country) {
                region.sortedVisitedCountries.append(country) { $0.code.localized() < $1.code.localized() }
            }
        }
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
