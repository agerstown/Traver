//
//  Regions.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/24/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class Region: NSObject {
    
    enum RegionType: Int {
        case europe
        case asia
        case northAmerica
        case southAmerica
        case australia
        case africa
    }
    
    var type: RegionType
    var name: String
    var countriesCodes: [String]
    
    init(type: RegionType, name: String, countriesCodes: [String]) {
        self.type = type
        self.name = name
        self.countriesCodes = countriesCodes
    }
    
    init(type: RegionType, name: String) {
        self.type = type
        self.name = name
        self.countriesCodes = [String]()
    }
    
    private static func sortCodesByLocilizedCountryName(codes: [String]) -> [String] {
        return codes.sorted { Countries.codesAndNames[$0]!.localized() < Countries.codesAndNames[$1]!.localized() }
    }
    
    static let europe = Region(type: .europe, name: "Europe".localized(), countriesCodes: sortCodesByLocilizedCountryName(codes: ["AL", "AM", "AT", "AZ", "BY", "BE", "BA", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "GE", "DE", "GR", "GL", "HU", "IS", "IE", "IT", "KZ", "XK", "LV", "LT", "LU", "MK", "MD", "ME", "NL", "NO", "PL", "PT", "RO", "RU", "RS", "SK", "SI", "ES", "SJ", "SE", "CH", "TR", "UA", "GB"]))
    
    static let asia = Region(type: .asia, name: "Asia".localized(), countriesCodes: sortCodesByLocilizedCountryName(codes: ["AF", "BD", "BT", "BN", "KH", "CN", "IN", "ID", "IR", "IQ", "IL", "JP", "JO", "KW", "KG", "LA", "LB", "MY", "MN", "MM", "NP", "KP", "OM", "PK", "PS", "PH", "QA", "SA", "KR", "LK", "SY", "TW", "TJ", "TH", "TM", "AE", "UZ", "VN", "YE"]))
    
    static let northAmerica = Region(type: .northAmerica, name: "North America".localized(), countriesCodes: sortCodesByLocilizedCountryName(codes: ["BS", "BZ", "CA", "CR", "CU", "DO", "SV", "GT", "HT", "HN", "JM", "MX", "NI", "PA", "PR", "TT", "US"]))
    
    static let southAmerica = Region(type: .southAmerica, name: "South America".localized(), countriesCodes: sortCodesByLocilizedCountryName(codes: ["AR", "BO", "BR", "CL", "CO", "EC", "FK", "GF", "GY", "PY", "PE", "SR", "UY", "VE"]))
    
    static let australia = Region(type: .australia, name: "Australia and Oceania".localized(), countriesCodes: sortCodesByLocilizedCountryName(codes: ["AU", "FJ", "NC", "NZ", "PG", "SB", "TL", "VU"]))
    
    static let africa = Region(type: .africa, name: "Africa".localized(), countriesCodes: sortCodesByLocilizedCountryName(codes: ["DZ", "AO", "BJ", "BW", "BF", "BI", "CM", "CF", "TD", "CD", "DJ", "EG", "GQ", "ER", "ET", "TF", "GA", "GM", "GH", "GN", "GW", "CI", "KE", "LS", "LR", "LY", "MG", "MW", "ML", "MR", "MA", "MZ", "NA", "NE", "NG", "CG", "RW", "SN", "SL", "SO", "ZA", "SS", "SD", "SZ", "TZ", "TG", "TN", "UG", "EH", "ZM", "ZW"]))
    
    static let regions = [europe, asia, northAmerica, southAmerica, australia, africa]
}
