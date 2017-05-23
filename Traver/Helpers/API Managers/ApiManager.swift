//
//  ApiManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/21/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import Alamofire

class ApiManager {
    
    let host = "http://traver-dev.us-east-1.elasticbeanstalk.com/"
    let photosHost = "https://s3.amazonaws.com/"
//    let host = "http://127.0.0.1:8000/"
//    let photosHost = "http://127.0.0.1:8000/"
    
    func stringOrNilIfEmpty(_ string: String) -> String? {
        if string.isEmpty {
            return nil
        } else {
            return string
        }
    }
    
    func showNoInternetErrorAlert(response: DataResponse<Any>) {
        let codeString = response.response?.statusCode != nil ? "\(response.response!.statusCode)" : "No Internet.".localized()
        StatusBarManager.shared.showCustomStatusBarError(text: "Error".localized() + ". " + "Check your Internet connection.".localized() + " " + "Status code".localized() + ": " + codeString)
    }
    
    func showNoInternetErrorAlert(error: Error) {
        StatusBarManager.shared.showCustomStatusBarError(text: "Check your Internet connection.".localized() + " " + "Error".localized() + ": " + error.localizedDescription)
    }
}
