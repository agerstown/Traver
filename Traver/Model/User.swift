//
//  User.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/22/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class User {
    
    static let sharedInstance = User()

    var token: String?
    var name: String?
    var photo: UIImage?
    var facebookID: String?
    var facebookEmail: String?
    var location: String?
    
    //var visitedCountriesCodes = [String]()
    //var visitedCountries: [Codes.Country] = []
    var visitedRegions = [Region]()
    
    var visitedCountries: [Country] {
        var countries = [Country]()
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
            User.sharedInstance.visitedRegions.removeObject(region)
        }
    }
    
    private func createCountryIfNeeded(for code: String, in region: Region) -> Country? {
        var country: Country?
        if !User.sharedInstance.visitedCountries.contains(where: { $0.code == code }) {
            country = Country(code: code, region: region)
            region.visitedCountries.append(country!)
        }
        return country
    }
    
    private func findOrCreateRegion(for countryCode: String) -> Region {
        let region: Region?
        let regionCode = Codes.countryToRegion[countryCode]!
        if User.sharedInstance.visitedRegions.contains(where: { $0.code == regionCode }) {
            let visitedRegions = User.sharedInstance.visitedRegions
            region = visitedRegions.filter { $0.code == regionCode }.first
        } else {
            region = Region(code: regionCode)
            User.sharedInstance.visitedRegions.append(region!)
        }
        return region!
    }
    
    private func findRegion(for country: Country) -> Region {
        return User.sharedInstance.visitedRegions.filter { $0.visitedCountries.contains(country) }.first!
    }
    
//    var visitedRegions: [Region] {
//        return Region.regions.filter { region in
//            var isRegionVisited = false
//            for countryCode in region.countriesCodes {
//                if User.sharedInstance.visitedCountriesCodes.contains(countryCode) {
//                    isRegionVisited = true
//                    break
//                }
//            }
//            return isRegionVisited
//        }
//    }
    
//    var visitedRegions: [Codes.Region] {
//        return [Codes.Region.EU]
//    }
    
//    func visitedCountriesCodes(in region: Region) -> [String] {
//        return User.sharedInstance.visitedCountries.filter { region.countriesCodes.contains($0) }
//    }
    
}
