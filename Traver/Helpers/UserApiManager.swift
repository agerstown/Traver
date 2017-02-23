//
//  UserApiManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 2/6/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper

class UserApiManager {
    
    static let shared = UserApiManager()
    
    // MARK: - Notifications
    let CountriesUpdatedNotification = NSNotification.Name(rawValue: "CountriesUpdatedNotification")
    let ProfileInfoUpdatedNotification = NSNotification.Name(rawValue: "ProfileInfoUpdatedNotification")
    
    // http://django-env.g6jwzu7n6j.us-east-1.elasticbeanstalk.com/
    
    // MARK: - GET and POST methods
    func getOrCreateUserWithFacebook(id: String) {
        
        let parameters: Parameters = [
            "facebook_id": id
        ]
    
        Alamofire.request("http://127.0.0.1:8000/users/get-user/", parameters: parameters).responseJSON { response in
            if response.response?.statusCode == 404 {
                
                let params: Parameters = [
                    "username": "fb\(User.shared.facebookID!)",
                    "profile": [
                        "name": User.shared.name!,
                        "facebook_id": User.shared.facebookID!,
                        "facebook_email": User.shared.facebookEmail!,
                        "location": User.shared.location!
                    ]
                ]
                
                self.createUser(parameters: params)
            } else if let value = response.result.value {
                
                let json = JSON(value)
                
                let token = json["token"].stringValue
                KeychainWrapper.standard.set(token, forKey: "token")
                User.shared.token = token
                
                self.updateUser(token: token) {
                    Alamofire.request("http://127.0.0.1:8000/users/get-user/", parameters: parameters).responseJSON { response in
                        if let resultValue = response.result.value {
                            self.parseAndSaveUser(user: User.shared, from: resultValue)
                        }
                    }
                }

            }
        }
    }
    
    func getUserInfo(user: User) {
        if let facebookID = user.facebookID {
            let parameters: Parameters = [
                "facebook_id": facebookID
            ]
            
            Alamofire.request("http://127.0.0.1:8000/users/get-user/", parameters: parameters).responseJSON { response in
                if let value = response.result.value {
                    self.parseAndSaveUser(user: user, from: value)
                }
            }
        }
    }
    
    // if a token is not nil and not empty - a person is logged in
    // then info in CoreData is updated only if post request was successful
    // if a user is not logged in - data is just saved in CoreData
    func updateUserInfo() {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            let parameters: Parameters = [
                "name": User.shared.name != nil ? User.shared.name! : "",
                "location": User.shared.location != nil ? User.shared.location! : ""
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            _ = Alamofire.request("http://127.0.0.1:8000/users/update-user-info/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 200 {
                    User.shared.updateInfo()
                } else {
                    self.showNoInternetErrorAlert(response: response)
                }
            }
        } else {
            User.shared.updateInfo()
        }
    }
    
    func updateCountryVisits(codes: [String], completion: (() -> Void)?) {
        //if !User.shared.visitedRegions.isEmpty {
            //let visitedCountriesCodes = User.shared.visitedCountries.map{ $0.code }
        
            if User.shared.token != nil && !User.shared.token!.isEmpty {
                let params: Parameters = [
                    "countries_codes": codes
                ]
                
                let headers: HTTPHeaders = [
                    "Authorization": "Token \(User.shared.token!)"
                ]
                
                _ = Alamofire.request("http://127.0.0.1:8000/visits/update-country-visits/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                    if response.response?.statusCode == 200 {
                        User.shared.updateCountryVisits(codes: codes)
                        if let completion = completion {
                            completion()
                        }
                        //NotificationCenter.default.post(name: self.CountriesUpdatedNotification, object: nil)
                    } else {
                        self.showNoInternetErrorAlert(response: response)
                    }
                }
            } else {
                User.shared.updateCountryVisits(codes: codes)
                if let completion = completion {
                    completion()
                }
                
                //NotificationCenter.default.post(name: self.CountriesUpdatedNotification, object: nil)
            }
        //}
    }
    
    private func showNoInternetErrorAlert(response: DataResponse<Any>) {
        let alert = UIAlertController(title: "Error".localized(), message: "Check your Internet connection. Status code" + ": \(response.response?.statusCode)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    private func parseAndSaveUser(user: User, from responseValue: Any) {
        let json = JSON(responseValue)
        
        let profile = json["profile"]
        user.facebookEmail = profile["facebook_email"].stringValue
        user.facebookID = profile["facebook_id"].stringValue
        user.location = profile["location"].stringValue
        user.name = profile["name"].stringValue
        
        let token = json["token"].stringValue
        KeychainWrapper.standard.set(token, forKey: "token")
        user.token = token
        
        user.updateInfo()
        
        NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
        
        let headers = [
            "Authorization": "Token \(user.token!)"
        ]
        
        Alamofire.request("http://127.0.0.1:8000/visits/get-user-country-visits/", headers: headers).responseJSON { response in
            if let value = response.result.value {
                var visitedCountriesCodes: [String] = []
                let countryVisits = JSON(value)
                
                for (_, countryVisit):(String, JSON) in countryVisits {
                    let code = countryVisit["country_code"].stringValue
                    visitedCountriesCodes.append(code)
                }
                
                user.updateCountryVisits(codes: visitedCountriesCodes)
                NotificationCenter.default.post(name: self.CountriesUpdatedNotification, object: nil)
            }
        }

    }
    
    private func createUser(parameters: Parameters) {
        Alamofire.request("http://127.0.0.1:8000/users/", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if response.response?.statusCode == 201 {
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    let token = json["token"].stringValue
                    KeychainWrapper.standard.set(token, forKey: "token")
                    User.shared.token = json["token"].stringValue
                    
                    NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
                    
                    self.createCountryVisits()
                }
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }
    
    private func createCountryVisits() {
        //if !User.shared.visitedRegions.isEmpty {
            let visitedCountriesCodes = User.shared.visitedCountries.map{ $0.code }
            
            let params: Parameters = [
                "countries_codes": visitedCountriesCodes
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            _ = Alamofire.request("http://127.0.0.1:8000/visits/create-country-visits/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 201 {
                    User.shared.updateCountryVisits(codes: visitedCountriesCodes)
                } else {
                    self.showNoInternetErrorAlert(response: response)
                }
            }
        //}
    }
    
    private func updateUser(token: String, completion: (() -> Void)?) {
        let headers = [
            "Authorization": "Token \(token)"
        ]
        
        let parameters: Parameters = [
            "facebook_id": User.shared.facebookID != nil ? User.shared.facebookID! : "",
            "facebook_email": User.shared.facebookEmail != nil ? User.shared.facebookEmail! : "",
            "name": User.shared.name != nil ? User.shared.name! : "",
            "location": User.shared.location != nil ? User.shared.location! : ""
        ]
        
        _ = Alamofire.request("http://127.0.0.1:8000/users/update-user/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { _ in
            if User.shared.visitedCountries.count == 0 {
                if let completion = completion {
                    completion()
                }
            } else {
                self.updateCountryVisits(codes: User.shared.visitedCountries.map{ $0.code }) {
                    NotificationCenter.default.post(name: self.CountriesUpdatedNotification, object: nil)
                }
                //self.createCountryVisits(completion: completion)
            }
        }
    }
    
}
