//
//  DetailedTipController.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/23/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class DetailedTipController: UIViewController {
    
    @IBOutlet weak var viewTip: UIView!
    
    @IBOutlet weak var imageViewAuthorPhoto: UIImageView!
    @IBOutlet weak var labelAuthorName: UILabel!
    @IBOutlet weak var labelAuthorLocation: UILabel!
    
    @IBOutlet weak var labelTipTitle: UILabel!
    @IBOutlet weak var textViewTipText: UITextView!
    @IBOutlet weak var lableTipCreationDate: UILabel!
    
    @IBOutlet weak var buttonReport: UIButton!
    
    var tip: Tip?
    
    var backgroundImage: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewTip.layer.cornerRadius = 10
        
        if let backgroundImage = backgroundImage {
            view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        
        imageViewAuthorPhoto.layer.cornerRadius = imageViewAuthorPhoto.frame.height / 2
        
        buttonReport.setTitle("Report".localized(), for: .normal)
        
        if let tip = tip {
            imageViewAuthorPhoto.image = tip.author.photo ?? UIImage(named: "default_photo")
            labelAuthorName.text = tip.author.name ?? "Anonymous".localized()
            labelAuthorLocation.text = tip.author.location == nil ? "" : "Lives in".localized() + " " + tip.author.location!
            
            labelTipTitle.text = tip.title
            textViewTipText.text = tip.text
            lableTipCreationDate.text = tip.dateString
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
        
        textViewTipText.setContentOffset(.zero, animated: false)
    }
    
    // MARK: - Actions
    @IBAction func buttonReportTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Report tip".localized(), message: "Do you want to report the tip for objectionable or abusive content?".localized(), preferredStyle: UIAlertControllerStyle.alert)
        let reportAction = UIAlertAction(title: "Report".localized(), style: .default) { _ in
            if let tip = self.tip {
                SlackHelper.shared.sendReport(tipID: tip.id) { success in
                    if success {
                        StatusBarManager.shared.showCustomStatusBarNeutral(text: "Your report has been sent succesfully!".localized())
                    }
                }
            }
        }
        let blockUserAction = UIAlertAction(title: "Block author".localized(), style: .default) { _ in
            if User.shared.token != nil {
                if let tip = self.tip {
                    UserApiManager.shared.blockUser(id: tip.author.id)
                }
            } else {
                let alert = UIAlertController(title: "Log in".localized(), message: "Please log in using your iCloud account (in Settigs) or Facebook to block someone".localized(), preferredStyle: UIAlertControllerStyle.alert)
                let connectFacebookAction = UIAlertAction(title: "Connect Facebook".localized(), style: .default) { _ in
                    FacebookHelper.shared.login()
                }
                let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
                alert.addAction(connectFacebookAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel)
        alert.addAction(reportAction)
        alert.addAction(blockUserAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension DetailedTipController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            return !(view.restorationIdentifier == "tipView" || view.isKind(of: UITextView.self) || view.isKind(of: UIButton.self))
        }
        return true
    }
    
    func handleTap(recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
