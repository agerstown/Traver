//
//  FacebookHelper.swift
//  Traver
//
//  Created by Natalia Nikitina on 1/8/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin
import Alamofire
import AlamofireImage
import SwiftyJSON

class FacebookHelper {
    
    static let shared = FacebookHelper()
    
    let loginManager = LoginManager()
    
    func login(completion: @escaping () -> Void) {
        if AccessToken.current != nil {
            let alert = UIAlertController(title: "Facebook".localized(), message: "Do you want to disconnect your account?".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default) { _ in
                self.loginManager.logOut()
            })
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        } else {
            loginManager.logIn([.publicProfile, .email, .userFriends, .custom("user_location")], viewController: nil) { loginResult in
                switch loginResult {
                case .failed(let error):
                    self.showErrorAlert(for: error)
                case .success(_, _, let accessToken):
                    let getUserDataRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, friends, location"], accessToken: accessToken, httpMethod: .GET, apiVersion: .defaultVersion)
                    getUserDataRequest.start { (response, result) in
                        switch result {
                        case .failed(let error):
                            self.showErrorAlert(for: error)
                        case .success(let graphResponse):
                            if let responseDictionary = graphResponse.dictionaryValue {
                                User.shared.facebookID = responseDictionary["id"] as! String?
                                User.shared.name = responseDictionary["name"] as! String?
                                User.shared.facebookEmail = responseDictionary["email"] as! String?
                                let location = responseDictionary["location"] as! NSDictionary
                                User.shared.location = location["name"] as! String?
                                
                                if let url = URL(string:"https://graph.facebook.com/\(User.shared.facebookID!)/picture?width=160&height=160") {
                                    Alamofire.request(url).responseImage { response in
                                        if let image = response.result.value {
                                            //User.shared.photo = image
                                            User.shared.photoData = UIImagePNGRepresentation(image) as Data?
                                            
                                            let parameters: Parameters = [
                                                "username": "fb\(User.shared.facebookID!)",
                                                "profile": [
                                                    "name": User.shared.name!,
                                                    "facebook_id": User.shared.facebookID!,
                                                    "facebook_email": User.shared.facebookEmail!,
                                                    "location": User.shared.location!
                                                ]
                                            ]
                                            
                                            
                                            
                                            // http://127.0.0.1:8000/
                                            // http://django-env.g6jwzu7n6j.us-east-1.elasticbeanstalk.com/
                                            
                                            Alamofire.request("http://127.0.0.1:8000/users/", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                                                if let value = response.result.value {
                                                    print(value)
                                                    let json = JSON(value)
                                                    User.shared.token = json["token"].stringValue
                                                }
                                                
                                                let visitedCountriesCodes = User.shared.visitedCountries.map{ $0.code }
                                                
                                                let params: Parameters = [
                                                    //"countries_codes": User.shared.visitedCountriesCodes
                                                    
                                                    "countries_codes": visitedCountriesCodes
                                                ]
                                                
                                                let headers: HTTPHeaders = [
                                                    "Authorization": "Token \(User.shared.token!)"
                                                ]
                                                
                                                Alamofire.request("http://127.0.0.1:8000/visits/create-country-visits/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response { response in
                                                    //print(response.error)
                                                    //print(response.response)
                                                }
                                            }
                                            
                                            completion()
                                        }
                                    }
                                }
                            }
                        }
                    }
                default: ()
                }
            }
        }
    }
    
    private func showErrorAlert(for error: Error) {
        let alert = UIAlertController(title: "Error".localized(), message: "Please contact the developer".localized()+"\n\(error.localizedDescription)", preferredStyle: .alert)
        // todo открывать форму отправки фидбека
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
}


//print(responseDictionary)
//                                        let getUserDataRequest = GraphRequest(graphPath: "me/friends", parameters: ["fields": "id, name, picture"], accessToken: accessToken, httpMethod: .GET, apiVersion: .defaultVersion)
//                                        getUserDataRequest.start { (response, result) in
//                                            switch result {
//                                            case .failed(let error):
//                                                print("error in graph request:", error)
//                                            case .success(let graphResponse):
//                                                if let responseDictionary = graphResponse.dictionaryValue {
//                                                    if let friends: Array<String> = responseDictionary["data"] as? Array<String> {
//                                                        print(friends.count)
//                                                    }
//                                                }
//                                            }
//                                        }
