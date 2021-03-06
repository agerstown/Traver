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
import CoreData

class UserApiManager: ApiManager {
    
    static let shared = UserApiManager()
    
    // MARK: - Notifications
    let ProfileInfoUpdatedNotification = NSNotification.Name(rawValue: "ProfileInfoUpdatedNotification")
    let PhotoUpdatedNotification = NSNotification.Name(rawValue: "PhotoUpdatedNotification")
    let FriendsUpdatedNotification = NSNotification.Name(rawValue: "FriendsUpdatedNotification")
    let UserBlockedNotification = NSNotification.Name(rawValue: "UserBlockedNotification")
    
    // MARK: - GET methods
    func getOrCreateUserWithFacebook(id: String, email: String?, name: String, location: String?, photo: UIImage?, friendsIDs: [String]?) {
        
        if User.shared.facebookID == nil {
            if User.shared.iCloudID != nil {
                self.updateFacebookInfo(id: id, email: email, name: name, location: location, photo: photo, friendsIDs: friendsIDs)
            } else {
            
                let parameters: Parameters = [
                    "facebook_id": id
                ]
                
                Alamofire.request(host + "users/get-user-with-facebook/", parameters: parameters).responseJSON { response in
                    if response.response?.statusCode == 404 {
                        self.createUserWithFacebook(id: id, email: email, name: name, location: location, photo: photo, friendsIDs: friendsIDs)
                    } else if let value = response.result.value {
                        
                        let json = JSON(value)
                        
                        let token = json["token"].stringValue
                        User.shared.token = token
                        
                        self.updateUser(user: User.shared) {
                            Alamofire.request(self.host + "users/get-user-with-facebook/", parameters: parameters).responseJSON { response in
                                if let resultValue = response.result.value {
                                    self.parseAndSaveUser(user: User.shared, from: resultValue)
                                }
                            }
                        }

                    }
                }
            }
        }
    }
    
    func getOrCreateUserWithICloud(user: User, id: String) {
        
        if user.iCloudID == nil {
            if user.facebookID != nil {
                self.updateICloudInfo(user: user, id: id)
            } else {
                
                let parameters: Parameters = [
                    "icloud_id": id
                ]
                
                Alamofire.request(host + "users/get-user-with-icloud/", parameters: parameters).responseJSON { response in
                    if response.response?.statusCode == 404 {
                        self.createUserWithICloud(user: user, id: id)
                    } else if let value = response.result.value {
                        
                        let json = JSON(value)
                        
                        let token = json["token"].stringValue
                        user.token = token
                        
                        self.updateUser(user: user) {
                            Alamofire.request(self.host + "users/get-user-with-icloud/", parameters: parameters).responseJSON { response in
                                if let resultValue = response.result.value {
                                    self.parseAndSaveUser(user: user, from: resultValue)
                                }
                            }
                        }
                        
                    }
                }
            }
        }

        
    }
    
    func getUserInfo(user: User, completion: @escaping (_ success: Bool) -> Void) {
        if let facebookID = user.facebookID {
            let parameters: Parameters = [
                "facebook_id": facebookID
            ]
            
            Alamofire.request(host + "users/get-user-with-facebook/", parameters: parameters).responseJSON { response in
                if let value = response.result.value {
                    self.parseAndSaveUser(user: user, from: value)
                    completion(true)
                } else {
                    completion(false)
                }
            }
        } else if let iCloudID = user.iCloudID {
            let parameters: Parameters = [
                "icloud_id": iCloudID
            ]
            
            Alamofire.request(host + "users/get-user-with-icloud/", parameters: parameters).responseJSON { response in
                if let value = response.result.value {
                    self.parseAndSaveUser(user: user, from: value)
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func getPhoto(user: User) {
        if let path = user.photoPath {
            if let url = URL(string: self.photosHost + "traver-media/" + path) {
                Alamofire.request(url).responseImage { response in
                    if let image = response.result.value {
                        user.photoData = UIImagePNGRepresentation(image) as Data?
                        CoreDataStack.shared.saveContext()
                        if user == User.shared {
                            NotificationCenter.default.post(name: self.PhotoUpdatedNotification, object: nil)
                        }
                    }
                }
            }
        }
    }
    
    func getFriends(user: User, completion: (() -> Void)? = nil) {
        
        if let token = user.token {
        
            let headers: HTTPHeaders = [
                "Authorization": "Token \(token)"
            ]
            
            Alamofire.request(host + "users/get-friends/", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if let friends = response.result.value as? NSArray {
                    
                    if User.shared.friends.count != 0 {
                        for friend in User.shared.friends {
                            if let friend = friend as? NSManagedObject {
                                CoreDataStack.shared.mainContext.delete(friend)
                            }
                        }
                    }
                    
                    if friends.count > 0 {
                        var friendsArray: [User] = []
                        
                        for friend in friends {
                            
                            let user = User(context: CoreDataStack.shared.mainContext)
                            friendsArray.append(user)
                            self.parseAndSaveUser(user: user, from: friend, withCountries: false)
                        }
                        
                        User.shared.friends = NSOrderedSet(array: friendsArray)
                    } else {
                        User.shared.friends = NSOrderedSet()
                    }
                    
                    CoreDataStack.shared.saveContext()
                    
                    if let completion = completion {
                        completion()
                    }
                    
                    NotificationCenter.default.post(name: self.FriendsUpdatedNotification, object: nil)
                }
            }
        }

    }
    
    func getFriendsForCurrentCountry(code: String,
                                     completion: @escaping (_ friendsNames: [String]) -> Void) {
        
        let parameters: Parameters = [
            "country_code": code
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        Alamofire.request(host + "users/get-friends-for-current-country/", method: .get, parameters: parameters, headers: headers).responseJSON { response in
            if let value = response.result.value {
                let json = JSON(value)
                if let names = json["friends_names"].arrayObject as? [String] {
                    completion(names)
                }
            }
        }
    }
    
    
    // MARK: - CREATE methods
    private func createUserWithFacebook(id: String, email: String?, name: String, location: String?, photo: UIImage?, friendsIDs: [String]?) {
        
        let name = User.shared.name != nil ? User.shared.name! : name
        let location = User.shared.location != nil ? User.shared.location! : location
        let photo = User.shared.photo != nil ? User.shared.photo! : photo
    
        var parameters = Parameters()
        parameters["username"] = "fb\(id)"
        
        var profileParameters = Parameters()
        profileParameters["name"] = name
        profileParameters["facebook_id"] = id
        
        if let email = email {
            profileParameters["facebook_email"] = email
        }
        if let location = location {
            profileParameters["location"] = location
        }
        
        parameters["profile"] = profileParameters
        
        Alamofire.request(host + "users/create-user/", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if response.response?.statusCode == 200 { 
                if let value = response.result.value {
                    let json = JSON(value)

                    User.shared.token = json["token"].stringValue
                    
                    User.shared.facebookID = id
                    User.shared.facebookEmail = email
                    User.shared.name = name
                    User.shared.location = location
                    
                    CoreDataStack.shared.saveContext()
                    
                    NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
                    
                    if let photo = photo {
                        self.updatePhoto(user: User.shared, photo: photo) {
                            let photoData = UIImagePNGRepresentation(photo)
                            User.shared.photoData = photoData
                            CoreDataStack.shared.saveContext()
                            
                            NotificationCenter.default.post(name: self.PhotoUpdatedNotification, object: nil)
                        }
                    }
                    
                    if let friendsIDs = friendsIDs {
                        self.updateFriends(friendsIDs: friendsIDs)
                    }
                    
                    CountryVisitApiManager.shared.createCountryVisits(user: User.shared)
                }
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }

    private func createUserWithICloud(user: User, id: String) {
    
        var parameters = Parameters()
        parameters["username"] = "ic\(id)"
        
        var profileParameters = Parameters()
        profileParameters["icloud_id"] = id
        if let name = user.name {
            profileParameters["name"] = name
        }
        if let location = user.location {
            profileParameters["location"] = location
        }
        
        parameters["profile"] = profileParameters
        
        Alamofire.request(host + "users/create-user/", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            if response.response?.statusCode == 200 {
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    user.token = json["token"].stringValue
                    
                    user.iCloudID = id
                    CoreDataStack.shared.saveContext()
                    
                    NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
                    
                    if let photo = user.photo {
                        self.updatePhoto(user: user, photo: photo) {
                            NotificationCenter.default.post(name: self.PhotoUpdatedNotification, object: nil)
                        }
                    }
                    
                    CountryVisitApiManager.shared.createCountryVisits(user: user)
                }
            }
        }
    }
    
    func setFeedbackEmail(email: String) {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            let params: Parameters = [
                "feedback_email": email
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            _ = Alamofire.request(host + "users/set-feedback-email/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 200 {
                    User.shared.feedbackEmail = email
                    CoreDataStack.shared.saveContext()
                }
            }
        } else {
            User.shared.feedbackEmail = email
            CoreDataStack.shared.saveContext()
        }
    }

    func setCurrentLocation(countryCode: String?, region: String?, completion: @escaping () -> Void) {
        var parameters = Parameters()
        if let countryCode = countryCode {
            parameters["country_code"] = countryCode
        }
        if let region = region {
            parameters["region"] = region
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        _ = Alamofire.request(host + "users/set-current-location/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                User.shared.currentCountryCode = countryCode
                User.shared.currentRegion = region
                CoreDataStack.shared.saveContext()
                completion()
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
        
    }
    
    func blockUser(id: String) {
        let parameters: Parameters = [
            "id": id
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        _ = Alamofire.request(host + "users/block-user/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                NotificationCenter.default.post(name: self.UserBlockedNotification, object: nil)
                StatusBarManager.shared.showCustomStatusBarNeutral(text: "User has been successfully blocked!".localized())
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }

    }
    
    // MARK: - UPDATE methods
    
    // if a token is not nil and not empty - a person is logged in
    // then info in CoreData is updated only if post request was successful
    // if a user is not logged in - data is just saved in CoreData
    func updateUserInfo(name: String, location: String?, completion: @escaping () -> Void) {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            var parameters = Parameters()
            parameters["name"] = name
            if let location = location {
                parameters["location"] = location
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            _ = Alamofire.request(host + "users/update-user-info/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.updateUserInfoInCoreData(name: name, location: location, completion: completion)
                } else {
                    self.showNoInternetErrorAlert(response: response)
                    completion()
                }
            }
        } else {
            updateUserInfoInCoreData(name: name, location: location, completion: completion)
        }
    }
    
    func updateFacebookInfo(id: String, email: String?, name: String,
                            location: String?, photo: UIImage?, friendsIDs: [String]?) {
        
        let name = User.shared.name != nil ? User.shared.name! : name
        let location = User.shared.location != nil ? User.shared.location! : location
        
        var parameters = Parameters()
        parameters["facebook_id"] = id
        parameters["name"] = name
        
        if let email = email {
            parameters["facebook_email"] = email
        }
        if let location = location {
            parameters["location"] = location
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        _ = Alamofire.request(host + "users/update-facebook-info/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 202 {
                if User.shared.photo == nil {
                    if let photo = photo {
                        self.updatePhoto(user: User.shared, photo: photo) {
                            let photoData = UIImagePNGRepresentation(photo)
                            User.shared.photoData = photoData
                            CoreDataStack.shared.saveContext()
                            NotificationCenter.default.post(name: self.PhotoUpdatedNotification, object: nil)
                        }
                    }
                }
                
                if let friendsIDs = friendsIDs {
                    self.updateFriends(friendsIDs: friendsIDs)
                }
                
                User.shared.facebookID = id
                User.shared.facebookEmail = email
                User.shared.name = name
                User.shared.location = location
                CoreDataStack.shared.saveContext()
                
                NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
            } else if response.response?.statusCode == 200 {
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    let token = json["token"].stringValue
                    User.shared.token = token
                    
                    let parameters: Parameters = [
                        "facebook_id": id
                    ]
                    
                    Alamofire.request(self.host + "users/get-user-with-facebook/", parameters: parameters).responseJSON { response in
                        if let resultValue = response.result.value {
                            self.parseAndSaveUser(user: User.shared, from: resultValue)
                        }
                    }
                }
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }
    
    func updateICloudInfo(user: User, id: String) {
    
        let parameters: Parameters = [
            "icloud_id": id
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(user.token!)"
        ]
        
        _ = Alamofire.request(host + "users/update-icloud-info/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 202 {
                user.iCloudID = id
                CoreDataStack.shared.saveContext()
            } else if response.response?.statusCode == 200 {
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    let token = json["token"].stringValue
                    user.token = token
                    
                    Alamofire.request(self.host + "users/get-user-with-icloud/", parameters: parameters).responseJSON { response in
                        if let resultValue = response.result.value {
                            self.parseAndSaveUser(user: user, from: resultValue)
                        }
                    }
                }
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }
    
    func updatePhoto(user: User, photo: UIImage, completion: @escaping () -> Void) {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            
            let photoData = UIImagePNGRepresentation(photo)!
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            let name = User.shared.username + String(Date().timeIntervalSince1970) + ".png"
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(photoData, withName: "photo", fileName: name, mimeType: "image/png")
            },
                             to: host + "users/update-user-photo/",
                             headers: headers,
                             encodingCompletion: { result in
                                switch result {
                                case .success(let upload, _, _):
                                    upload.responseJSON { response in
                                        if let value = response.result.value {
                                            let json = JSON(value)
                                            let path = json["path"].stringValue
                                            User.shared.photoPath = path
                                            CoreDataStack.shared.saveContext()
                                        }
                                    }
                                    completion()
                                case .failure(let error):
                                    self.showNoInternetErrorAlert(error: error)
                                }
            })
        } else {
            completion()
        }
    }
    
    private func updateUser(user: User, completion: (() -> Void)?) {
        let headers = [
            "Authorization": "Token \(user.token!)"
        ]
        
        var parameters = Parameters()
        
        if let facebookId = user.facebookID {
            parameters["facebook_id"] = facebookId
        }
        if let facebookEmail = user.facebookEmail {
            parameters["facebook_email"] = facebookEmail
        }
        if let name = user.name {
            parameters["name"] = name
        }
        if let location = user.location {
            parameters["location"] = location
        }
        if let iCloudId = user.iCloudID {
            parameters["icloud_id"] = iCloudId
        }
        
        _ = Alamofire.request(host + "users/update-user/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                if let photo = User.shared.photo {
                    self.updatePhoto(user: user, photo: photo) {
                        NotificationCenter.default.post(name: self.PhotoUpdatedNotification, object: nil)
                        self.updateCountryVisistsIfNeeded(user: user, completion: completion)
                    }
                } else {
                    self.updateCountryVisistsIfNeeded(user: user, completion: completion)
                }
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }
    
    func updateCountryVisistsIfNeeded(user: User, completion: (() -> Void)?) {
        if user.visitedCountries.count == 0 {
            if let completion = completion {
                completion()
            }
        } else {
            CountryVisitApiManager.shared.updateCountryVisits(user: user, codes: user.visitedCountriesArray.map{ $0.code }) {
                if let completion = completion {
                    completion()
                }
            }
        }
    }
    
    func updateFriends(friendsIDs: [String]) {
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        let parameters: Parameters = [
            "friends_ids": friendsIDs
        ]
        
        _ = Alamofire.request(host + "users/update-friends/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if let friends = response.result.value as? NSArray {
                
                var friendsArray: [User] = []
                
                for friend in friends {
                    
                    let user = User(context: CoreDataStack.shared.mainContext)
                    friendsArray.append(user)
                    
                    self.parseAndSaveUser(user: user, from: friend, withCountries: false)
                }
                User.shared.friends = NSOrderedSet(array: friendsArray)
                CoreDataStack.shared.saveContext()
                
                NotificationCenter.default.post(name: self.FriendsUpdatedNotification, object: nil)
            }
        }
    }
    
    func setAitaTokens(accessToken: String, refreshToken: String) {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            let parameters: Parameters = [
                "access_token": accessToken,
                "refresh_token": refreshToken
            ]
            
            _ = Alamofire.request(host + "users/set-aita-tokens/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 200 {
                    self.setAitaTokensInCoreData(accessToken: accessToken, refreshToken: refreshToken)
                }
            }
        } else {
            setAitaTokensInCoreData(accessToken: accessToken, refreshToken: refreshToken)
        }
    }
    
    func setAitaTokensInCoreData(accessToken: String, refreshToken: String) {
        User.shared.aitaAccessToken = accessToken
        User.shared.aitaRefreshToken = refreshToken
        CoreDataStack.shared.saveContext()
    }
    
    func updateAitaAccessToken(_ accessToken: String, completion: @escaping () -> Void) {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            let parameters: Parameters = [
                "access_token": accessToken
            ]
            
            _ = Alamofire.request(host + "users/update-aita-access-token/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                if response.response?.statusCode == 200 {
                    User.shared.aitaAccessToken = accessToken
                    CoreDataStack.shared.saveContext()
                    completion()
                }
            }
        } else {
            User.shared.aitaAccessToken = accessToken
            CoreDataStack.shared.saveContext()
            completion()
        }
    }
    
    // MARK: - DELETE methods
    func disconnectFacebook() {
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        _ = Alamofire.request(host + "users/disconnect-facebook/", method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                User.shared.facebookID = nil
                User.shared.facebookEmail = nil
                CoreDataStack.shared.saveContext()
            }
        }
    }
    
    
    // MARK: - Helper methods
    private func parseAndSaveUser(user: User, from responseValue: Any, withCountries: Bool = true) {
        let json = JSON(responseValue)
        
        let profile = json["profile"]
        
        user.facebookEmail = stringOrNilIfEmpty(profile["facebook_email"].stringValue)
        user.facebookID = stringOrNilIfEmpty(profile["facebook_id"].stringValue)
        user.location = stringOrNilIfEmpty(profile["location"].stringValue)
        user.name = stringOrNilIfEmpty(profile["name"].stringValue)
        user.iCloudID = stringOrNilIfEmpty(profile["icloud_id"].stringValue)
        user.feedbackEmail = stringOrNilIfEmpty(profile["feedback_email"].stringValue)
        user.currentCountryCode = stringOrNilIfEmpty(profile["current_country_code"].stringValue)
        user.currentRegion = stringOrNilIfEmpty(profile["current_region"].stringValue)
        user.aitaAccessToken = stringOrNilIfEmpty(profile["aita_access_token"].stringValue)
        user.aitaRefreshToken = stringOrNilIfEmpty(profile["aita_refresh_token"].stringValue)
        
        if json["num_countries"].int != nil {
            user.numberOfVisitedCountries = NSNumber(integerLiteral: json["num_countries"].intValue)
        }
        
        user.id = json["id"].stringValue
        user.token = json["token"].stringValue
        user.mainUser = NSNumber(value: user == User.shared)
        
        CoreDataStack.shared.saveContext()
        
        if user == User.shared {
            NotificationCenter.default.post(name: self.ProfileInfoUpdatedNotification, object: nil)
        }
        
        if let photoPath = stringOrNilIfEmpty(profile["photo_path"].stringValue) {
            if user.photoPath != photoPath {
                user.photoPath = photoPath
                CoreDataStack.shared.saveContext()
                if user == User.shared {
                    getPhoto(user: user)
                }
            }
        }
        
        if withCountries {
            CountryVisitApiManager.shared.getUserCountryVisits(user: user)
        }
    }
    
    private func updateUserInfoInCoreData(name: String, location: String?, completion: @escaping () -> Void) {
        User.shared.name = name.isEmpty ? nil : name
        if let location = location {
            User.shared.location = location
        }
        CoreDataStack.shared.saveContext()
        completion()
    }
    
}
