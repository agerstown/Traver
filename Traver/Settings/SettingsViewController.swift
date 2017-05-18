//
//  SettingsViewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 11/21/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import Photos
import FacebookCore
import FacebookLogin

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var tableViewSettings: UITableView!
    @IBOutlet weak var cellImportFromPhotos: UITableViewCell!
    @IBOutlet weak var cellFacebook: UITableViewCell!
    @IBOutlet weak var textViewFeedback: UITextView!
    @IBOutlet weak var buttonSendFeedback: UIButton!
    
    let sectionsHeaders = ["Import".localized(), "Accounts".localized(), "Support and feedback".localized()];
    let sectionsFooters = ["It may take some time, just wait a little.".localized(), "", ""];
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Settings".localized()
        
        cellImportFromPhotos.textLabel?.text = "Import countries from Photos".localized()
        
        cellFacebook.textLabel?.text = "Facebook".localized()
        cellFacebook.detailTextLabel?.text = FacebookHelper.shared.isConnected() ? "Connected".localized() : "Not connected".localized()
        
        textViewFeedback.layer.cornerRadius = 5
        textViewFeedback.layer.borderColor = UIColor.gray.cgColor
        textViewFeedback.layer.borderWidth = 0.5
        textViewFeedback.delegate = self
        
        buttonSendFeedback.setTitle("Send".localized(), for: .normal)
        buttonSendFeedback.layer.cornerRadius = 5
        
        tableViewSettings.delegate = self
        
        tapGestureRecognizer.addTarget(self, action: #selector(handleTap(recognizer:)))
        tapGestureRecognizer.isEnabled = false
        //tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateAccountsInfo), name: FacebookHelper.shared.AccountInfoUpdatedNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func buttonSendFeedbackTapped(_ sender: Any) {
        if textViewFeedback.text.isEmpty {
            StatusBarManager.shared.showCustomStatusBarError(text: "Please write something.".localized())
            textViewFeedback.becomeFirstResponder()
        } else {
            self.performSegue(withIdentifier: "segueToEmailController", sender: nil)
        }
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? EmailController {
            controller.feedbackDelegate = self
            controller.backgroundImage = Bluring.blurBackground(backgroundController: self)
            controller.feedbackText = textViewFeedback.text
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsHeaders[section]
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionsFooters[section]
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableViewSettings.deselectRow(at: indexPath, animated: true)
        if let cell = tableViewSettings.cellForRow(at: indexPath) {
            switch (cell) {
            case cellImportFromPhotos:
                PhotosAccessManager.shared.importVisitedCountries(controller: self)
            case cellFacebook:
                FacebookHelper.shared.login()
            default: ()
            }
        }
    }
    
    // MARK: - Notifications
    func updateAccountsInfo() {
        
        UIView.transition(with: cellFacebook.detailTextLabel!,
                          duration: 0.3,
                          options: [.transitionCrossDissolve],
                          animations: {
                            self.cellFacebook.detailTextLabel?.text = FacebookHelper.shared.isConnected() ? "Connected".localized() : "Not connected".localized()
        }, completion: nil)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension SettingsViewController: UIGestureRecognizerDelegate {
    func handleTap(recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            textViewFeedback.resignFirstResponder()
            tapGestureRecognizer.isEnabled = false
        }
    }
}

extension SettingsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        tapGestureRecognizer.isEnabled = true
    }
}

// MARK: - FeedbackDelegate
extension SettingsViewController: FeedbackDelegate {
    func feedbackSuccessfullySent() {
        textViewFeedback.text = ""
    }
}
