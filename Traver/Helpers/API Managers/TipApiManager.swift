//
//  TipApiManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/21/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class TipApiManager: ApiManager {
    
    static let shared = TipApiManager()
    
    // MARK: - CREATE methods
    func createTip(countryCode: String, title: String, text: String) {
        let parameters: Parameters = [
            "country_code": countryCode,
            "title": title,
            "text": text
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        _ = Alamofire.request(host + "tips/create-tip/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response)
            if response.response?.statusCode == 200 {
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    let creationDateString = json["creation_date"].stringValue
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    if let creationDate = dateFormatter.date(from: creationDateString) {
                        if let country = Codes.Country.all.filter({ $0.code == countryCode }).first {
                            let tip = Tip(authorName: User.shared.name ?? "Anonymous".localized(),
                                          authorPhoto: User.shared.photo ?? UIImage(named: "default_photo")!,
                                          country: country, title: title, text: text, creationDate: creationDate)
                            User.shared.tips.append(tip)
                        }
                    }
                }
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }
    
}
