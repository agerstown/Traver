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
    let PhotoUpdatedNotification = NSNotification.Name(rawValue: "PhotoUpdatedNotification")
    
    // http://django-env.g6jwzu7n6j.us-east-1.elasticbeanstalk.com/
    
    // MARK: - GET methods
    func getOrCreateUserWithFacebook(id: String, email: String, name: String, location: String, photo: UIImage) {
        
        let parameters: Parameters = [
            "facebook_id": id
        ]
    
        Alamofire.request("http://127.0.0.1:8000/users/get-user/", parameters: parameters).responseJSON { response in
            if response.response?.statusCode == 404 {
                self.createUser(id: id, email: email, name: name, location: location, photo: photo)
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
    
    func getUserCountryVisits(user: User) {
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
    
    func getPhoto() {
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        Alamofire.request("http://127.0.0.1:8000/users/get-user-photo/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let value = response.result.value {
                let json = JSON(value)
                let path = json["path"].stringValue
                
                if let url = URL(string: "http://127.0.0.1:8000/site-media/media/" + path) {
                    Alamofire.request(url).responseImage { response in
                        if let image = response.result.value {
                            User.shared.photoData = UIImagePNGRepresentation(image) as Data?
                            User.shared.updateInfo()
                            NotificationCenter.default.post(name: self.PhotoUpdatedNotification, object: nil)
                        }
                    }
                }
            }
        }
        
    }
    
    
    // MARK: - CREATE methods
    private func createUser(id: String, email: String, name: String, location: String, photo: UIImage) {
        
        let parameters: Parameters = [
            "username": "fb\(id)",
            "profile": [
                "name": name,
                "facebook_id": id,
                "facebook_email": email,
                "location": location
            ]
        ]
        
        Alamofire.request("http://127.0.0.1:8000/users/", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if response.response?.statusCode == 201 {
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    let token = json["token"].stringValue
                    KeychainWrapper.standard.set(token, forKey: "token")
                    User.shared.token = json["token"].stringValue
                    
                    User.shared.facebookID = id
                    User.shared.facebookEmail = email
                    User.shared.name = name
                    User.shared.location = location
                    User.shared.updateInfo()
                    
                    NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
                    
                    self.updatePhoto(photo: photo) {
                        let photoData = UIImagePNGRepresentation(photo)
                        User.shared.photoData = photoData
                        User.shared.updateInfo()
                    }
                    
                    self.createCountryVisits()
                }
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }

    private func createCountryVisits() {
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
    }
    
    
    // MARK: - UPDATE methods
    
    // if a token is not nil and not empty - a person is logged in
    // then info in CoreData is updated only if post request was successful
    // if a user is not logged in - data is just saved in CoreData
    func updateUserInfo(name: String, location: String, completion: @escaping () -> Void) {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            let parameters: Parameters = [
                "name": name,
                "location": location
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            _ = Alamofire.request("http://127.0.0.1:8000/users/update-user-info/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.updateUserInfoInCoreData(name: name, location: location, completion: completion)
                } else {
                    self.showNoInternetErrorAlert(response: response)
                }
            }
        } else {
            updateUserInfoInCoreData(name: name, location: location, completion: completion)
        }
    }
    
    func updateCountryVisits(codes: [String], completion: (() -> Void)?) {
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
                } else {
                    self.showNoInternetErrorAlert(response: response)
                }
            }
        } else {
            User.shared.updateCountryVisits(codes: codes)
            if let completion = completion {
                completion()
            }
        }
    }
    
    func updatePhoto(photo: UIImage, completion: @escaping () -> Void) {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            
            let photoData = UIImagePNGRepresentation(photo)!
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(photoData, withName: "photo", fileName: "photo.png", mimeType: "image/png")
            },
                             to: "http://127.0.0.1:8000/users/update-user-photo/",
                             headers: headers,
                             encodingCompletion: { result in
                                switch result {
                                case .success(_, _, _):
                                    completion()
                                case .failure(let error):
                                    self.showNoInternetErrorAlert(error: error)
                                }
            })
        } else {
            completion()
        }
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
            
            if let photo = User.shared.photo {
                self.updatePhoto(photo: photo) {
                    NotificationCenter.default.post(name: self.PhotoUpdatedNotification, object: nil)
                    self.updateCountryVisistsIfNeeded(completion: completion)
                }
            } else {
                self.updateCountryVisistsIfNeeded(completion: completion)
            }
        }
    }
    
    func updateCountryVisistsIfNeeded(completion: (() -> Void)?) {
        if User.shared.visitedCountries.count == 0 {
            if let completion = completion {
                completion()
            }
        } else {
            self.updateCountryVisits(codes: User.shared.visitedCountries.map{ $0.code }) {
                NotificationCenter.default.post(name: self.CountriesUpdatedNotification, object: nil)
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
            
            _ = Alamofire.request("http://127.0.0.1:8000/visits/delete-country-visit/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
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
    
    
    // MARK: - Helper methods
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
        
        getPhoto()
        getUserCountryVisits(user: user)
    }
    
    private func showNoInternetErrorAlert(response: DataResponse<Any>) {
        let alert = UIAlertController(title: "Error".localized(), message: "Check your Internet connection. Status code".localized() + ": \(response.response?.statusCode)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    private func showNoInternetErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Error".localized(), message: "Check your Internet connection. Status code" + ": " + error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    private func updateUserInfoInCoreData(name: String, location: String, completion: @escaping () -> Void) {
        User.shared.name = name
        User.shared.location = location
        User.shared.updateInfo()
        completion()
    }
    
}
