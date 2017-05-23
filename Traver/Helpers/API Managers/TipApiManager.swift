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
import Nuke

class TipApiManager: ApiManager {
    
    static let shared = TipApiManager()
      
    // MARK: - GET methods
    func getExistingTipsCountries(completion: @escaping (_ countryCodes: [String: Int]) -> Void) {
        Alamofire.request(host + "tips/get-existing-tips-countries/", method: .get, parameters: nil).responseJSON { response in
            if let value = response.result.value {
                let json = JSON(value)
                let countryCodesJSON = json["country_codes"].arrayValue
                var countryCodes: [String: Int] = [:]
                for codeObject in countryCodesJSON {
                    let code = codeObject["country_code"].stringValue
                    let count = codeObject["count"].intValue
                    countryCodes[code] = count
                }
                completion(countryCodes)
            }
        }
        
    }
    
    func getTipsForCountry(_ country: Codes.Country, completion: @escaping (_ tips: [Tip]) -> Void) {
        let parameters: Parameters = [
            "country_code": country.code
        ]
    
        Alamofire.request(host + "tips/get-tips-for-country/", method: .get, parameters: parameters).responseJSON { response in
            if let tipsJSON = response.result.value as? NSArray {
                var tips: [Tip] = []
                for tip in tipsJSON {
                    let json = JSON(tip)
                    
                    let creationDateString = json["creation_date"].stringValue

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"

                    let creationDate = dateFormatter.date(from: creationDateString) ?? Date()
                    
                    let title = json["title"].stringValue
                    let text = json["text"].stringValue
                    
                    let user = json["user"]
                    let username = user["username"].stringValue
                    let token = user["token"].stringValue
                    
                    let name = user["profile"]["name"].stringValue
                    let photoPath = user["profile"]["photo_path"].stringValue
                    
                    let author = TipAuthor(username: username, token: token)
                    
                    if !name.isEmpty {
                        author.name = name
                    }
                    
                    if !photoPath.isEmpty {
                        author.photoPath = photoPath
                    }

                    let tip = Tip(author: author, country: country, title: title, text: text, creationDate: creationDate)
                    tips.append(tip)
                }
                completion(tips)
            }
        }
    }
    
    func getAuthorPhoto(author: TipAuthor, putInto imageView: UIImageView) {
        imageView.image = UIImage(named: "default_photo")
        if let path = author.photoPath {
            if let url = URL(string: photosHost + "traver-media/" + path) {
                Nuke.loadImage(with: url, into: imageView)
            }
        }
    }
    
    // MARK: - CREATE methods
    func createTip(countryCode: String, title: String, text: String, completion: @escaping () -> Void) {
        let parameters: Parameters = [
            "country_code": countryCode,
            "title": title,
            "text": text
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        _ = Alamofire.request(host + "tips/create-tip/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                completion()
                StatusBarManager.shared.showCustomStatusBarNeutral(text: "Your tip was created successfully!".localized())
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }
    
}
