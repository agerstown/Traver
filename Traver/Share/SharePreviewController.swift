//
//  SharePreviewController.swift
//  Traver
//
//  Created by Natalia Nikitina on 4/13/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class SharePreviewController: UIViewController {
    
    @IBOutlet weak var imageViewSharePicture: UIImageView!
    @IBOutlet weak var buttonShare: UIButton!
    
    var backgroundImage: UIImage?
    
    var sharePicture: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let backgroundImage = backgroundImage {
            view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        
        buttonShare.setTitle("Share".localized(), for: .normal)
        buttonShare.layer.cornerRadius = 5
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        imageViewSharePicture.isUserInteractionEnabled = true
        tapGestureRecognizer.delegate = self
        
        sharePicture = ShareManager.shared.getSharePicture()
        imageViewSharePicture.image = sharePicture
    }
    
    // MARK: - Actions
    @IBAction func buttonShareTapped(_ sender: Any) {
        if let picture = sharePicture {
            ShareManager.shared.shareProfile(picture: picture, controller: self)
        }
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension SharePreviewController: UIGestureRecognizerDelegate {
    func handleTap(recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            let view = recognizer.view
            let location = recognizer.location(in: view)
            if let subview = view?.hitTest(location, with: nil) {
                if !(subview is UIImageView) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
