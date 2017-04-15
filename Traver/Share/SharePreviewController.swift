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
    
    var backgroundController: UIViewController?
    
    var sharePicture: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let backgroundController = backgroundController {
            backgroundController.tabBarController?.tabBar.isHidden = true
            
            UIGraphicsBeginImageContextWithOptions(backgroundController.view.bounds.size, false, 0)
            backgroundController.view.drawHierarchy(in: backgroundController.view.bounds, afterScreenUpdates: true)
            var snapshot = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let tintColor = UIColor(white:0.11, alpha:0.75) //0.11 0.8
            snapshot = snapshot.applyBlurWithRadius(3, tintColor:tintColor, saturationDeltaFactor:1.8, maskImage:nil)! //5 1.8
            
            view.backgroundColor = UIColor(patternImage: snapshot)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabBar = self.backgroundController?.tabBarController?.tabBar {
            tabBar.frame.origin.y += tabBar.frame.size.height
            self.backgroundController?.tabBarController?.tabBar.isHidden = false
            UIView.animate(withDuration: 0.3) {
                tabBar.frame.origin.y -= tabBar.frame.size.height
            }
        }
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
