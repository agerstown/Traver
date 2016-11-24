//
//  Regions.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/24/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class Regions {
    
    static let europe = ["AL", "AM", "AT", "AZ", "BA", "BE", "BG", "BY", "CH", "CY", "CZ", "DE", "DK", "EE", "ES", "FI", "FR", "GB", "GE", "GL", "GR", "HR", "HU", "IE", "IS", "IT", "XK", "KZ", "LT", "LU", "LV", "MD", "ME", "MK", "NL", "NO", "PL", "PT", "RO", "RS", "RU", "SE", "SI", "SK", "TR", "UA", "SJ"]
    
    static let asia = ["AE", "AF", "BD", "BN", "BT", "CN", "ID", "IL", "IN", "IQ", "IR", "JO", "JP", "KP", "KR", "KW", "LK", "MM", "MN", "MY", "NP", "OM", "PH", "PK", "PS", "QA", "SA", "SY", "TH", "TJ", "TM", "TW", "UZ", "VN", "YE", "KG", "KH", "LA", "LB"]
    
    static let northAmerica = ["BS", "BZ", "CA", "CR", "CU", "DO", "GT", "HN", "HT", "JM", "MX", "NI", "PA", "PR", "SV", "TT", "US"]
    
    static let southAmerica = ["AR", "BO", "BR", "CL", "CO", "EC", "FK", "GF", "GY", "PE", "PY", "SR", "UY", "VE"]
    
    static let australia = ["AU", "FJ", "NZ", "NC", "PG", "SB", "TL", "VU"]
    
    static let africa = ["AO", "BF", "BI", "BJ", "BW", "CD", "CF", "CG", "CI", "CM", "DJ", "EG", "EH", "ER", "ET", "GA", "GH", "GM", "GN", "GQ", "KE", "LR", "LS", "LY", "MA", "MG", "ML", "MR", "MW", "MZ", "NA", "NE", "NG", "SD", "SL", "SN", "SO", "SS", "SZ", "TD", "TG", "TN", "TZ", "UG", "ZA", "ZM", "ZW", "DZ", "GW", "RW", "TF"]
    
    enum Region: Int {
        case europe
        case asia
        case northAmerica
        case southAmerica
        case australia
        case africa
        
        var countriesCodes: [String] {
            switch self {
            case .europe:
                return Regions.europe
            case .asia:
                return Regions.asia
            case .northAmerica:
                return Regions.northAmerica
            case .southAmerica:
                return Regions.southAmerica
            case .australia:
                return Regions.australia
            default:
                return Regions.africa
            }
        }
        
        var regionName: String {
            switch self {
            case .europe:
                return "Europe"
            case .asia:
                return "Asia"
            case .northAmerica:
                return "North America"
            case .southAmerica:
                return "South America"
            case .australia:
                return "Australia"
            default:
                return "Africa"
            }
        }
    }
    
    static let regions: [Region] = [.europe, .asia, .northAmerica, .southAmerica, .australia, .africa]
    
}
