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
    
    func isConnected() -> Bool {
        return AccessToken.current != nil
    }
    
    func login() {
        if AccessToken.current != nil {
            let alert = UIAlertController(title: "Facebook".localized(), message: "Do you want to disconnect your account?".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No".localized(), style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes".localized(), style: .default) { _ in
                self.loginManager.logOut()
                if User.shared.iCloudID != nil {
                    UserApiManager.shared.disconnectFacebook()
                }
            })
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        } else {
            loginManager.logIn([.publicProfile, .email, .userFriends, .custom("user_location")], viewController: nil) { loginResult in
                switch loginResult {
                case .failed(let error):
                    self.showErrorAlert(for: error)
                case .success(_, _, let accessToken):
                    let getUserDataRequest = GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, friends, picture.width(100).height(100), location"], accessToken: accessToken, httpMethod: .GET, apiVersion: .defaultVersion)
                    getUserDataRequest.start { (response, result) in
                        switch result {
                        case .failed(let error):
                            self.showErrorAlert(for: error)
                        case .success(let graphResponse):
                            if let responseDictionary = graphResponse.dictionaryValue {
                                
                                print(responseDictionary)
                                
                                let id = responseDictionary["id"] as! String
                                let email = responseDictionary["email"] as? String
                                let name = responseDictionary["name"] as! String
                                
                                let locationDict = responseDictionary["location"] as? NSDictionary
                                let location = locationDict?["name"] as? String
                                
                                let picture = responseDictionary["picture"] as! NSDictionary
                                let pictureData = picture["data"] as! NSDictionary
                                
                                let isSilhouette = pictureData["is_silhouette"] as! Bool
                                
                                if isSilhouette {
                                    UserApiManager.shared.getOrCreateUserWithFacebook(id: id, email: email, name: name, location: location, photo: nil)
                                } else {
                                    let url = pictureData["url"] as! String
                                    Alamofire.request(url).responseImage { response in
                                        if let image = response.result.value {
                                            UserApiManager.shared.getOrCreateUserWithFacebook(id: id, email: email, name: name, location: location, photo: image)
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
        //todo открывать форму отправки фидбека
        alert.addAction(UIAlertAction(title: "OK".localized(), style: .cancel))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
    
}
