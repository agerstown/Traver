//
//  EmailController.swift
//  Traver
//
//  Created by Natalia Nikitina on 4/30/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import Alamofire

protocol FeedbackDelegate: class {
    func feedbackSuccessfullySent()
}

class EmailController: UIViewController {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var buttonSendFeedback: UIButton!
    
    var backgroundImage: UIImage?
    
    var feedbackText: String?
    
    weak var feedbackDelegate: FeedbackDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let backgroundImage = backgroundImage {
            view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        
        labelTitle.text = "Please write your e-mail if you want us to answer you.".localized()
        
        if let email = User.shared.feedbackEmail {
            textFieldEmail.text = email
        } else if let email = User.shared.facebookEmail {
            textFieldEmail.text = email
        }
        
        buttonSendFeedback.setTitle("Send".localized(), for: .normal)
        buttonSendFeedback.layer.cornerRadius = 5
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func buttonSendFeedbackTapped(_ sender: Any) {
        
        let email = textFieldEmail.text ?? ""
        
        if email.contains("@") || email.isEmpty {
            if User.shared.feedbackEmail == nil || User.shared.feedbackEmail != email {
                UserApiManager.shared.setFeedbackEmail(email: email)
            }
            
            SlackHelper.shared.sendFeedback(feedbackText: feedbackText, email: email) { success in
                if success {
                    self.feedbackDelegate?.feedbackSuccessfullySent()
                    StatusBarManager.shared.showCustomStatusBarNeutral(text: "Your feedback has been sent!".localized())
                } else {
                    StatusBarManager.shared.showCustomStatusBarError(text: "Error! Please try to send your feedback later.".localized())
                }
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            StatusBarManager.shared.showCustomStatusBarError(text: "The email is not valid!".localized())
            textFieldEmail.becomeFirstResponder()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EmailController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            return !(view.restorationIdentifier == "viewEmail")
        }
        return true
    }
    

    func handleTap(recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            if textFieldEmail.isFirstResponder {
                textFieldEmail.resignFirstResponder()
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
