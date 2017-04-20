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

    static let shared = StatusBarManager()
    
    private func showCustomStatusBar(text: String, color: UIColor) {
        let notification = CWStatusBarNotification()
        notification.notificationAnimationType = .overlay
        notification.notificationAnimationInStyle = .top
        notification.display(withMessage: text, forDuration: TimeInterval(3))
    }
    
    func showCustomStatusBarNeutral(text: String) {
        showCustomStatusBar(text: text, color: UIColor.blue)
    }
    
    func showCustomStatusBarError(text: String) {
        showCustomStatusBar(text: text, color: UIColor.red)
    }
}
