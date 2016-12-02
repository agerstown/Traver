//
//  StatusBarHelper.swift
//  Traver
//
//  Created by Natalia Nikitina on 12/2/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation

class StatusBarHelper {

    static let sharedInstance = StatusBarHelper()
    
    func showCustomStatusBar(with text: String, backgroundColor: UIColor? = nil) {
        
        let notification = CWStatusBarNotification()
        notification.notificationAnimationType = .overlay
        if let color = backgroundColor {
            notification.notificationLabelBackgroundColor = color
        }
        notification.display(withMessage: text, forDuration: TimeInterval(2))
    }
}
