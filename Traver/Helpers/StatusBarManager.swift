//
//  StatusBarManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 12/2/16.
//  Copyright © 2016 Natalia Nikitina. All rights reserved.
//

import Foundation
import CWStatusBarNotification

class StatusBarManager {

    static let sharedInstance = StatusBarManager()
    
    func showCustomStatusBar(with text: String) {
        let notification = CWStatusBarNotification()
        notification.notificationAnimationType = .overlay
        notification.notificationAnimationInStyle = .top
        notification.notificationLabelBackgroundColor = UIColor.blue
        notification.display(withMessage: text, forDuration: TimeInterval(3))
    }
}
