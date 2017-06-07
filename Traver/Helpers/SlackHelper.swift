//
//  SlackHelper.swift
//  Traver
//
//  Created by Natalia Nikitina on 6/7/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import Alamofire

class SlackHelper {
    
    static let shared = SlackHelper()
    
    private let feedbacksChannelURL = "https://hooks.slack.com/services/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"
    private let reportsChannelURL = "https://hooks.slack.com/services/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"
    
    func sendFeedback(feedbackText: String?, email: String, completion: @escaping (_ success: Bool) -> Void) {
        let parameters: Parameters = [
            "text": feedbackText ?? "no text",
            "username": email
        ]
        
        _ = Alamofire.request(feedbacksChannelURL, method: .post, parameters: parameters,
                              encoding: JSONEncoding.default).response { response in
            completion(response.response?.statusCode == 200)
        }

    }
    
    func sendReport(tipID: Int, completion: @escaping (_ success: Bool) -> Void) {
        
        var email = "no email"
        
        if User.shared.feedbackEmail != nil {
            email = User.shared.feedbackEmail!
        } else if User.shared.facebookEmail != nil {
            email = User.shared.facebookEmail!
        }
        
        var userID = "no id"
        if User.shared.id != nil {
            userID = User.shared.id!
        }
        
        let parameters: Parameters = [
            "text": "Reporter userID: \(userID)" + "\ntipID: \(tipID)",
            "username": email
        ]
        
        _ = Alamofire.request(reportsChannelURL, method: .post, parameters: parameters,
                              encoding: JSONEncoding.default).response { response in
            completion(response.response?.statusCode == 200)
        }
    }
    
}
