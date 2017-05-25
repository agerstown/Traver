//
//  DetailedTipController.swift
//  Traver
//
//  Created by Natalia Nikitina on 5/23/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation

class DetailedTipController: UIViewController {
    
    @IBOutlet weak var imageViewAuthorPhoto: UIImageView!
    @IBOutlet weak var labelAuthorName: UILabel!
    @IBOutlet weak var labelAuthorLocation: UILabel!
    
    @IBOutlet weak var labelTipTitle: UILabel!
    @IBOutlet weak var textViewTipText: UITextView!
    @IBOutlet weak var lableTipCreationDate: UILabel!
    
    var tip: Tip?
    
    var backgroundImage: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let backgroundImage = backgroundImage {
            view.backgroundColor = UIColor(patternImage: backgroundImage)
        }
        
        imageViewAuthorPhoto.layer.cornerRadius = imageViewAuthorPhoto.frame.height / 2
        
        if let tip = tip {
            imageViewAuthorPhoto.image = tip.author.photo
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
        
    }
}

// MARK: - UIGestureRecognizerDelegate
extension DetailedTipController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            return !(view.restorationIdentifier == "tipView" || view.isKind(of: UITextView.self))
        }
        return true
    }
    
    func handleTap(recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
