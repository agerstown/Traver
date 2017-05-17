//
//  EmailController.swift
//  Traver
//
//  Created by Natalia Nikitina on 4/30/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import Alamofire

protocol FeedbackDelegate {
    func feedbackSuccessfullySent()
}

class EmailController: UIViewController {
    
    let slackFeedbackURL = "https://hooks.slack.com/services/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"
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var buttonSendFeedback: UIButton!
    
    var backgroundImage: UIImage?
    
    var feedbackText: String?
    
    var feedbackDelegate: FeedbackDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let backgroundImage = backgroundImage {
            view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        
        textFieldEmail.adjustsFontSizeToFitWidth = true
        if let email = User.shared.feedbackEmail {
            textFieldEmail.text = email
        } else if let email = User.shared.facebookEmail {
            textFieldEmail.text = email
        }
        
        buttonSendFeedback.setTitle("Send".localized(), for: .normal)
        buttonSendFeedback.layer.cornerRadius = 5
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func buttonSendFeedbackTapped(_ sender: Any) {
        
        let email = textFieldEmail.text ?? ""
        
        if !email.contains("@") {
            StatusBarManager.shared.showCustomStatusBarError(text: "The email is not valid!".localized())
            textFieldEmail.becomeFirstResponder()
        } else {
            
            if User.shared.feedbackEmail == nil || User.shared.feedbackEmail != email {
                UserApiManager.shared.setFeedbackEmail(email: email)
            }
            
            let parameters: Parameters = [
                    "text": feedbackText ?? "no text",
                    "username": email
            ]
            
            _ = Alamofire.request(slackFeedbackURL, method: .post, parameters: parameters, encoding: JSONEncoding.default).response { response in
                if response.response?.statusCode == 200 {
                    self.feedbackDelegate?.feedbackSuccessfullySent()
        
                    self.dismiss(animated: true, completion: nil)
                    StatusBarManager.shared.showCustomStatusBarNeutral(text: "Your feedback has been sent!".localized())
                } else {
                    self.dismiss(animated: true, completion: nil)
                    StatusBarManager.shared.showCustomStatusBarError(text: "Error! Please try to send your feedback later.".localized())
                }
            }
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EmailController: UIGestureRecognizerDelegate {
    func handleTap(recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            if textFieldEmail.isFirstResponder {
                textFieldEmail.resignFirstResponder()
            } else {
                let view = recognizer.view
                let location = recognizer.location(in: view)
                if let subview = view?.hitTest(location, with: nil) {
                    if subview.restorationIdentifier != "viewEmail" && !(subview is UILabel) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
