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

class FacebookHelper {
    
    static let sharedInstance = FacebookHelper()
    
    let loginManager = LoginManager()
    
    func login(with completion: @escaping () -> Void) {
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
                                User.sharedInstance.facebookID = responseDictionary["id"] as! String?
                                User.sharedInstance.name = responseDictionary["name"] as! String?
                                User.sharedInstance.facebookEmail = responseDictionary["email"] as! String?
                                let location = responseDictionary["location"] as! NSDictionary
                                User.sharedInstance.facebookLocation = location["name"] as! String?
                                
                                let url = URL(string:"https://graph.facebook.com/\(User.sharedInstance.facebookID!)/picture?width=160&height=160")
                                DispatchQueue.global().async {
                                    let data = try? Data(contentsOf: url!)
                                    DispatchQueue.main.async {
                                        User.sharedInstance.photo = UIImage(data: data!)
                                    }
                                }
                                completion()
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
