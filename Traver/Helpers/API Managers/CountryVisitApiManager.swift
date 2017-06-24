//
//  CountryVisitApiManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/21/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class CountryVisitApiManager: ApiManager {
    
    static let shared = CountryVisitApiManager()
    
    // MARK: - GET methods
    func getUserCountryVisits(user: User) {
        let headers = [
            "Authorization": "Token \(user.token!)"
        ]
        
        Alamofire.request(host + "visits/get-user-country-visits/", headers: headers).responseJSON { response in
            if let value = response.result.value {
                var visitedCountriesCodes: [String] = []
                let countryVisits = JSON(value)
                
                for (_, countryVisit):(String, JSON) in countryVisits {
                    let code = countryVisit["country_code"].stringValue
                    visitedCountriesCodes.append(code)
                }
                
                user.updateCountryVisits(codes: visitedCountriesCodes)
            }
        }
    }
    
    // MARK: - CREATE methods
    func createCountryVisits(user: User) {
        if user.visitedCountries.count != 0 {
            
            let visitedCountriesCodes = user.visitedCountriesArray.map { $0.code }
            
            let params: Parameters = [
                "countries_codes": visitedCountriesCodes
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(user.token!)"
            ]
            
            _ = Alamofire.request(host + "visits/create-country-visits/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 201 {
                    user.updateCountryVisits(codes: visitedCountriesCodes)
                } else {
                    self.showNoInternetErrorAlert(response: response)
                }
            }
        }
    }

    // MARK: - UPDATE methods
    func updateCountryVisits(user: User, codes: [String], completion: (() -> Void)?) {
        if user.token != nil && !user.token!.isEmpty {
            let params: Parameters = [
                "countries_codes": codes
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(user.token!)"
            ]
            
            _ = Alamofire.request(host + "visits/update-country-visits/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 200 {
                    user.updateCountryVisits(codes: codes)
                    if let completion = completion {
                        completion()
                    }
                } else {
                    self.showNoInternetErrorAlert(response: response)
                }
            }
        } else {
            user.updateCountryVisits(codes: codes)
            if let completion = completion {
                completion()
            }
        }
    }
    
    func addCountryVisit(code: String, completion: (() -> Void)?) {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            let params: Parameters = [
                "country_code": code
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            _ = Alamofire.request(host + "visits/add-country-visit/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 201 {
                    User.shared.addCountryVisit(code: code)
                    if let completion = completion {
                        completion()
                    }
                }
            }
        } else {
            User.shared.addCountryVisit(code: code)
            if let completion = completion {
                completion()
            }
        }
    }
    
    func addCountryVisits(codes: [String], completion: (() -> Void)?) {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            let params: Parameters = [
                "country_codes": codes
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            _ = Alamofire.request(host + "visits/add-country-visits/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 201 {
                    
                    User.shared.addCountryVisits(codes: codes)
                    if let completion = completion {
                        completion()
                    }
                }
            }
        } else {
            User.shared.addCountryVisits(codes: codes)
            if let completion = completion {
                completion()
            }
        }
    }

    
    // MARK: - DELETE methods
    func deleteCountryVisit(country: Country, completion: (() -> Void)?) {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            let params: Parameters = [
                "code": country.code
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            _ = Alamofire.request(host + "visits/delete-country-visit/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 200 {
                    User.shared.removeCountryVisit(country: country)
                    if let completion = completion {
                        completion()
                    }
                } else {
                    self.showNoInternetErrorAlert(response: response)
                }
            }
        } else {
            User.shared.removeCountryVisit(country: country)
            if let completion = completion {
                completion()
            }
        }
    }
}
