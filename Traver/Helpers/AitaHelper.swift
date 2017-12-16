//
//  AitaHelper.swift
//  Traver
//
//  Created by Natalia Nikitina on 6/23/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class AitaHelper {
    
    static let shared = AitaHelper()
    
    let activityIndicator = UIActivityIndicatorView()
    
    let host = "https://iappintheair.appspot.com/"
    let clientID = "b3253ae6-b9ea-41a3-98a9-c9077961b1b0"
    let clientSecret = "HF14)8zA1RqujDlxt!t8I!MRX.MMuoFNPWUt6H.uRoU617uX7kaf2Ot8GG8Cwul8-iZleATt!91TYYLF)KlH"
    let redirectURL = "traver://aita"
    
    var authorisationLink: String {
        return host + "oauth/authorize?client_id=\(clientID)&response_type=code&redirect_uri=\(redirectURL)&scope=user_info"
    }
    
    func importCountries(code: String, completion: (() -> Void)?) {
        _ = Alamofire.request(host + "/oauth/token?client_id=\(clientID)&client_secret=\(clientSecret)&grant_type=authorization_code&code=\(code)&redirect_uri=\(redirectURL)").responseJSON { response in
            if let value = response.result.value {
                let json = JSON(value)
                let accessToken = json["access_token"].stringValue
                let refreshToken = json["refresh_token"].stringValue
                UserApiManager.shared.setAitaTokens(accessToken: accessToken, refreshToken: refreshToken)
                self.getUserCountries(accessToken: accessToken, refreshToken: refreshToken, completion: completion)
            }
        }
    }
    
    func getUserCountries(accessToken: String, refreshToken: String, completion: (() -> Void)?) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(accessToken)"
        ]
        
        _ = Alamofire.request(self.host + "api/v1/me", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            if response.response?.statusCode == 401 {
                _ = Alamofire.request(self.host + "/oauth/token?client_id=\(self.clientID)&client_secret=\(self.clientSecret)&grant_type=refresh_token&refresh_token=\(refreshToken)").responseJSON { response in
                    if let value = response.result.value {
                        let json = JSON(value)
                        let accessToken = json["access_token"].stringValue
                        UserApiManager.shared.updateAitaAccessToken(accessToken) {
                            self.getUserCountries(accessToken: accessToken, refreshToken: refreshToken, completion: completion)
                            return
                        }
                    }
                }
            } else {
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    let countries = json["data"]["countries"]
                    var countriesCodes = countries.map { $0.0 }
                    
                    let allCodes = Codes.Country.all.map { $0.code }
                    countriesCodes = countriesCodes.filter { allCodes.contains($0) }
                    
                    let currentCountrireCodes = User.shared.visitedCountriesArray.map { $0.code }
                    countriesCodes = countriesCodes.filter { !currentCountrireCodes.contains($0) }
                    
                    CountryVisitApiManager.shared.addCountryVisits(codes: countriesCodes) {
                        StatusBarManager.shared.showCustomStatusBarNeutral(text: "%d new countries were succesfully imported from AitA".localized(for: countriesCodes.count))
                        if let completion = completion {
                            completion()
                        }
                    }
                }
            }
        }
    }
}
