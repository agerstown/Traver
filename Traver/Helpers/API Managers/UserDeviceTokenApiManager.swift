//
//  UserDeviceTokenApiManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 7/10/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import Alamofire

class UserDeviceTokenApiManager: ApiManager {
    
    static let shared = UserDeviceTokenApiManager()
    
    // MARK: - UPDATE methods
    func saveDeviceToken(token: String) {
        if User.shared.token != nil && !User.shared.token!.isEmpty {
            let deviceID = UIDevice.current.identifierForVendor!.uuidString
            
            let parameters: Parameters = [
                "device_id": deviceID,
                "token": token,
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Token \(User.shared.token!)"
            ]
            
            _ = Alamofire.request(host + "devicetokens/save-device-token/", method: .post, parameters: parameters,
                                  encoding: JSONEncoding.default, headers: headers)
        }
    }
    
}
