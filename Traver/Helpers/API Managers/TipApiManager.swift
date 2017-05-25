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
            self.parseCountryCodes(response: response, completion: completion)
        }
    }
    
    func getExistingTipsCountriesFriends(completion: @escaping (_ countryCodes: [String: Int]) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]

        Alamofire.request(host + "tips/get-existing-tips-countries-friends/", method: .get,
                          parameters: nil, headers: headers).responseJSON { response in
            self.parseCountryCodes(response: response, completion: completion)
        }
    }
    
    private func parseCountryCodes(response: DataResponse<Any>, completion: @escaping (_ countryCodes: [String: Int]) -> Void) {
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
    
    func getTipsForCountry(_ country: Codes.Country, completion: @escaping (_ tips: [Tip]) -> Void) {
        let parameters: Parameters = [
            "country_code": country.code
        ]
    
        Alamofire.request(host + "tips/get-tips-for-country/", method: .get, parameters: parameters).responseJSON { response in
            if let tipsJSON = response.result.value as? NSArray {
                let tips = self.parseTips(json: tipsJSON, country: country)
                completion(tips)
            }
        }
    }
    
    private func parseTips(json: NSArray, country: Codes.Country?) -> [Tip] {
        var tips: [Tip] = []
        for tip in json {
            let json = JSON(tip)
            
            let updateDateString = json["update_date"].stringValue
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let updateDate = dateFormatter.date(from: updateDateString) ?? Date()
            
            let id = json["id"].intValue
            
            let title = json["title"].stringValue
            let text = json["text"].stringValue
            
            let user = json["user"]
            
            let token = user["token"].stringValue
            let profile = user["profile"]
            
            let name = self.stringOrNilIfEmpty(profile["name"].stringValue)
            let photoPath = self.stringOrNilIfEmpty(profile["photo_path"].stringValue)
            let location = self.stringOrNilIfEmpty(profile["location"].stringValue)
            
            let author = TipAuthor(token: token)
            
            author.name = name
            author.photoPath = photoPath
            author.location = location
            
            if let country = country {
                let tip = Tip(id: id, author: author, country: country, title: title, text: text, updateDate: updateDate)
                tips.append(tip)
            } else {
                let countryCode = json["country_code"].stringValue
                if let country = Codes.Country.all.filter( { $0.code == countryCode } ).first {
                    let tip = Tip(id: id, author: author, country: country, title: title, text: text, updateDate: updateDate)
                    tips.append(tip)
                }
            }
        }
        return tips
    }
    
    func getAuthorPhoto(author: TipAuthor, putInto imageView: UIImageView) {
        imageView.image = UIImage(named: "default_photo")
        if let path = author.photoPath {
            if let url = URL(string: photosHost + "traver-media/" + path) {
                Nuke.loadImage(with: url, into: imageView) { handler in
                    let image = handler.0.value
                    author.photo = image
                    imageView.image = author.photo
                }
            }
        }
    }
    
    func getUserTips(completion: @escaping (_ tips: [Tip]) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        Alamofire.request(host + "tips/get-user-tips/", method: .get, parameters: nil,
                          headers: headers).responseJSON { response in
            if let tipsJSON = response.result.value as? NSArray {
                let tips = self.parseTips(json: tipsJSON, country: nil)
                completion(tips)
            }
        }
    }
    
    // MARK: - CREATE methods
    func createTip(country: Codes.Country, title: String, text: String, completion: @escaping (_ tip: Tip) -> Void) {
        let parameters: Parameters = [
            "country_code": country.code,
            "title": title,
            "text": text
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        _ = Alamofire.request(host + "tips/create-tip/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    let updateDateString = json["update_date"].stringValue
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let updateDate = dateFormatter.date(from: updateDateString) ?? Date()
                    
                    let id = json["id"].intValue
                    
                    let author = TipAuthor(user: User.shared)
                    
                    let tip = Tip(id: id, author: author, country: country, title: title, text: text, updateDate: updateDate)
                    completion(tip)
                }
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }
    
    // MARK: - UPDATE methods
    func updateTip(id: Int, title: String, text: String, completion: @escaping (_ date: Date) -> Void) {
        let parameters: Parameters = [
            "tip_id": id,
            "title": title,
            "text": text
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        _ = Alamofire.request(host + "tips/update-tip/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                
                if let value = response.result.value {
                    let json = JSON(value)
                    let updateDateString = json["update_date"].stringValue
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let updateDate = dateFormatter.date(from: updateDateString) ?? Date()
                    
                    completion(updateDate)
                }
                
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
        
    }
    
    
    // MARK: - DELETE methods
    func deleteTip(id: Int, completion: @escaping () -> Void) {
        let parameters: Parameters = [
            "tip_id": id
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": "Token \(User.shared.token!)"
        ]
        
        _ = Alamofire.request(host + "tips/delete-tip/", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            if response.response?.statusCode == 200 {
                completion()
            } else {
                self.showNoInternetErrorAlert(response: response)
            }
        }
    }
}
