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
    
    let imagePicker = UIImagePickerController()
    var selectedImage: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile".localized()
        textFieldName.placeholder = "Name".localized()
        textFieldLocation.placeholder = "Location".localized()
        
        buttonPhoto.imageView?.contentMode = .scaleAspectFill
        setPhoto(User.shared.photo)
        
        textFieldName.text = User.shared.name
        textFieldLocation.text = User.shared.location
        
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
    }
    
    func setPhoto(_ photo: UIImage?) {
        if photo != nil {
            buttonPhoto.imageView?.layer.cornerRadius = buttonPhoto.frame.height / 2
            buttonPhoto.setImage(photo, for: .normal)
        } else {
            buttonPhoto.setImage(UIImage(named: "default_photo"), for: .normal)
        }
    }
    
    // MARK: - Actions
    @IBAction func buttonCancelTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonSaveTapped(_ sender: UIBarButtonItem) {
        let name = textFieldName.text ?? ""
        let location = textFieldLocation.text
        if location != "" && name == "" {
            let alert = UIAlertController(title: "Fill info".localized(), message: "Please fill your name".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: .default))
            present(alert, animated: true)
        } else {
            UserApiManager.shared.updateUserInfo(name: name, location: location) {
                self.dismiss(animated: true, completion: nil)
            }
            if let image = selectedImage {
                UserApiManager.shared.updatePhoto(photo: image) {
                    User.shared.photoData = UIImagePNGRepresentation(image)
                    User.shared.updateInfo()
                }
            }
        }
    }
    
    @IBAction func buttonPhotoTapped(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = pickedImage
            self.setPhoto(selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
