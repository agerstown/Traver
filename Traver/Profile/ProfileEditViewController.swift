//
//  ProfileEditViewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 1/8/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class ProfileEditViewController: UITableViewController {
    
    @IBOutlet var tableViewProfileInfo: UITableView!
    @IBOutlet weak var buttonPhoto: UIButton!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldLocation: UITextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile".localized()
        textFieldName.placeholder = "Name".localized()
        textFieldLocation.placeholder = "Location".localized()
        
        if User.sharedInstance.photo != nil {
            buttonPhoto.imageView?.layer.cornerRadius = buttonPhoto.frame.height / 2
            buttonPhoto.setImage(User.sharedInstance.photo, for: .normal)
        } else {
            buttonPhoto.setImage(UIImage(named: "default_photo"), for: .normal)
        }
        
        textFieldName.text = User.sharedInstance.name
        textFieldLocation.text = User.sharedInstance.location
    }
    
    // MARK: - Actions
    @IBAction func buttonCancelTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonSaveTapped(_ sender: UIBarButtonItem) {
        User.sharedInstance.name = textFieldName.text
        User.sharedInstance.location = textFieldLocation.text
        CoreDataStack.sharedInstance.saveContext()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonPhotoTapped(_ sender: UIButton) {
        
    }
}