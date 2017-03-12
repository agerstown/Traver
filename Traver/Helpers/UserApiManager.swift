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
//import SwiftKeychainWrapper

class UserApiManager {
    
    static let shared = UserApiManager()
    
    let host = "http://127.0.0.1:8000" // http://django-env.g6jwzu7n6j.us-east-1.elasticbeanstalk.com/
    
    // MARK: - Notifications
    let CountriesUpdatedNotification = NSNotification.Name(rawValue: "CountriesUpdatedNotification")
    let ProfileInfoUpdatedNotification = NSNotification.Name(rawValue: "ProfileInfoUpdatedNotification")
    let PhotoUpdatedNotification = NSNotification.Name(rawValue: "PhotoUpdatedNotification")
    
    // MARK: - GET methods
    func getOrCreateUserWithFacebook(id: String, email: String, name: String, location: String, photo: UIImage) {
        
        let parameters: Parameters = [
            "facebook_id": id
        ]
    
        Alamofire.request(host + "/users/get-user-with-facebook/", parameters: parameters).responseJSON { response in
            if response.response?.statusCode == 404 {
                if User.shared.iCloudID != nil {
                    self.updateFacebookInfo(id: id, email: email, name: name, location: location, photo: photo)
                } else {
//                    self.createUserWithFacebook(id: id, email: email, name: name, location: location, photo: photo)
                    self.createUserWithFacebook(id: id, email: email, name: User.shared.name != nil ? User.shared.name! : name, location: User.shared.location != nil ? User.shared.location! : location, photo: User.shared.photo != nil ? User.shared.photo! : photo) // check about photo: у юзера мб стоит дефолтное всегда? что если из фб пришло nil фото?
                }
            } else if let value = response.result.value {
                
                let json = JSON(value)
                
                let token = json["token"].stringValue
                //KeychainWrapper.standard.set(token, forKey: "token")
                User.shared.token = token
                
                self.updateUser(token: token) {
                    Alamofire.request(self.host + "/users/get-user-with-facebook/", parameters: parameters).responseJSON { response in
                        if let resultValue = response.result.value {
                            self.parseAndSaveUser(user: User.shared, from: resultValue)
                        }
                    }
                }

            }
        }
    }
    
    func getOrCreateUserWithICloud(id: String, name: String?, location: String?, photo: UIImage?) {
        
        let parameters: Parameters = [
            "icloud_id": id
        ]
        
        Alamofire.request(host + "/users/get-user-with-icloud/", parameters: parameters).responseJSON { response in
            if response.response?.statusCode == 404 {
                if User.shared.facebookID != nil {
                    self.updateICloudInfo(id: id)
//                    self.updateFacebookInfo(id: id, email: email, name: name, location: location, photo: photo) {
//                        NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
//                    }
                } else {
                    self.createUserWithICloud(id: id, name: User.shared.name != nil ? User.shared.name! : name, location: User.shared.location != nil ? User.shared.location! : location, photo: User.shared.photo != nil ? User.shared.photo! : photo)
                }
            } else if let value = response.result.value {
                
                let json = JSON(value)
                
                let token = json["token"].stringValue
                //KeychainWrapper.standard.set(token, forKey: "token")
                User.shared.token = token
                
                self.updateUser(token: token) {
                    Alamofire.request(self.host + "/users/get-user-with-icloud/", parameters: parameters).responseJSON { response in
                        if let resultValue = response.result.value {
                            self.parseAndSaveUser(user: User.shared, from: resultValue)
                        }
                    }
                }
                
            }
        }
    }
    
    func getUserInfo(user: User, completion: @escaping () -> Void) {
        if let facebookID = user.facebookID {
            let parameters: Parameters = [
                "facebook_id": facebookID
            ]
            
            Alamofire.request(host + "/users/get-user-with-facebook/", parameters: parameters).responseJSON { response in
                if let value = response.result.value {
                    self.parseAndSaveUser(user: user, from: value)
                    completion()
                }
            }
        } else if let iCloudID = user.iCloudID {
            let parameters: Parameters = [
                "icloud_id": iCloudID
            ]
            
            Alamofire.request(host + "/users/get-user-with-icloud/", parameters: parameters).responseJSON { response in
                if let value = response.result.value {
                    self.parseAndSaveUser(user: user, from: value)
                    completion()
                }
            }
        }
    }
    
    func getUserCountryVisits(user: User) {
        let headers = [
            "Authorization": "Token \(user.token!)"
        ]
        
        Alamofire.request(host + "/visits/get-user-country-visits/", headers: headers).responseJSON { response in
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
        
        Alamofire.request(host + "/users/get-user-photo/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let value = response.result.value {
                let json = JSON(value)
                let path = json["path"].stringValue
                
                if let url = URL(string: self.host + "/site-media/media/" + path) {
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
    private func createUserWithFacebook(id: String, email: String, name: String, location: String, photo: UIImage) {
        
        let parameters: Parameters = [
            "username": "fb\(id)",
            "profile": [
                "name": name,
                "facebook_id": id,
                "facebook_email": email,
                "location": location
            ]
        ]
        
        Alamofire.request(host + "/users/", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if response.response?.statusCode == 201 {
                if let value = response.result.value {
                    let json = JSON(value)
                    
//                    let token = json["token"].stringValue
//                    KeychainWrapper.standard.set(token, forKey: "token")
                    User.shared.token = json["token"].stringValue
                    
                    User.shared.facebookID = id
                    User.shared.facebookEmail = email
                    User.shared.name = name
                    User.shared.location = location
                    //User.shared.updateInfo()
                    
                    NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
                    
                    self.updatePhoto(photo: photo) {
                        let photoData = UIImagePNGRepresentation(photo)
                        User.shared.photoData = photoData
                        User.shared.updateInfo()
                        
                        NotificationCenter.default.post(name: self.PhotoUpdatedNotification, object: nil)
                    }
                    
                    self.createCountryVisits()
                }
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }

    private func createUserWithICloud(id: String, name: String?, location: String?, photo: UIImage?) {
        
        let parameters: Parameters = [
            "username": "ic\(id)",
            "profile": [
                "name": name ?? "",
                "location": location ?? "",
                "icloud_id": id
            ]
        ]
        
        Alamofire.request(host + "/users/", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if response.response?.statusCode == 201 {
                if let value = response.result.value {
                    let json = JSON(value)
                    
//                    let token = json["token"].stringValue
//                    KeychainWrapper.standard.set(token, forKey: "token")
                    User.shared.token = json["token"].stringValue
                    
                    User.shared.iCloudID = id
                    User.shared.name = name
                    User.shared.location = location
                    //User.shared.updateInfo()
                    
                    NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
                    
                    if let photo = photo {
                        self.updatePhoto(photo: photo) {
                            let photoData = UIImagePNGRepresentation(photo)
                            User.shared.photoData = photoData
                            User.shared.updateInfo()
                            
                            NotificationCenter.default.post(name: self.PhotoUpdatedNotification, object: nil)
                        }
                    }
                    
                    self.createCountryVisits()
                }
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
        
        _ = Alamofire.request(host + "/visits/create-country-visits/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
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
            
            _ = Alamofire.request(host + "/users/update-user-info/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
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
    
    func updateFacebookInfo(id: String, email: String, name: String, location: String, photo: UIImage) {
        
        let name = User.shared.name != nil ? User.shared.name! : name
        let location = User.shared.location != nil ? User.shared.location! : location
        
        let parameters: Parameters = [
            "facebook_id": id,
            "facebook_email": email,
            "name": name,
            "location": location
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        _ = Alamofire.request(host + "/users/update-facebook-info/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                if User.shared.photo == nil {
                    self.updatePhoto(photo: photo) {
                        let photoData = UIImagePNGRepresentation(photo)
                        User.shared.photoData = photoData
                        User.shared.updateInfo()
                        NotificationCenter.default.post(name: self.PhotoUpdatedNotification, object: nil)
                    }
                }
                
                User.shared.facebookID = id
                User.shared.facebookEmail = email
                User.shared.name = name
                User.shared.location = location
                User.shared.updateInfo()
                
                NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }
    
    func updateICloudInfo(id: String) {
        
        let parameters: Parameters = [
            "icloud_id": id
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        _ = Alamofire.request(host + "/users/update-icloud-info/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                User.shared.iCloudID = id
                User.shared.updateInfo()
                
                NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
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
            
            _ = Alamofire.request(host + "/visits/update-country-visits/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
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
                             to: host + "/users/update-user-photo/",
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
            "location": User.shared.location != nil ? User.shared.location! : "",
            "icloud_id": User.shared.iCloudID != nil ? User.shared.iCloudID! : ""
        ]
        
//        let parameters: Parameters = [
//            "facebook_id": facebookID != nil ? facebookID! : "",
//            "facebook_email": facebookEmail != nil ? facebookEmail! : "",
//            "name": name != nil ? name! : "",
//            "location": location != nil ? location! : "",
//            "icloud_id": iCloudID != nil ? iCloudID! : ""
//        ]
        
        _ = Alamofire.request(host + "/users/update-user/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                if let photo = User.shared.photo {
                    self.updatePhoto(photo: photo) {
                        NotificationCenter.default.post(name: self.PhotoUpdatedNotification, object: nil)
                        self.updateCountryVisistsIfNeeded(completion: completion)
                    }
                } else {
                    self.updateCountryVisistsIfNeeded(completion: completion)
                }
            } else {
                self.showNoInternetErrorAlert(response: response)
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
            
            _ = Alamofire.request(host + "/visits/delete-country-visit/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
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
        
        user.facebookEmail = stringOrNilIfEmpty(profile["facebook_email"].stringValue)
        user.facebookID = stringOrNilIfEmpty(profile["facebook_id"].stringValue)
        user.location = stringOrNilIfEmpty(profile["location"].stringValue)
        user.name = stringOrNilIfEmpty(profile["name"].stringValue)
        user.iCloudID = stringOrNilIfEmpty(profile["icloud_id"].stringValue)
        
//        let token = json["token"].stringValue
//        KeychainWrapper.standard.set(token, forKey: "token")
//        user.token = token
        user.token = json["token"].stringValue
        
        user.updateInfo()
        
        NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
        
        getPhoto()
        getUserCountryVisits(user: user)
    }
    
    private func stringOrNilIfEmpty(_ string: String) -> String? {
        if string.isEmpty {
            return nil
        } else {
            return string
        }
    }
    
    private func showNoInternetErrorAlert(response: DataResponse<Any>) {
        let alert = UIAlertController(title: "Error".localized(), message: "Check your Internet connection. Status code".localized() + ": \(response.response?.statusCode)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    private func showNoInternetErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Error".localized(), message: "Check your Internet connection. Error".localized() + ": " + error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
    private func updateUserInfoInCoreData(name: String, location: String, completion: @escaping () -> Void) {
        User.shared.name = name.isEmpty ? nil : name
        User.shared.location = location.isEmpty ? nil : location
        User.shared.updateInfo()
        completion()
    }
    
}
