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
        let notification = createNotificationTopOverlay(color: color)
        notification.display(withMessage: text, forDuration: TimeInterval(3))
    }
    
    func showCustomStatusBarWithCompletion(text: String, color: UIColor, completion: @escaping () -> Void) {
        let notification = createNotificationTopOverlay(color: color)
        notification.display(withMessage: text) {
            notification.dismiss()
            completion()
        }
    }
    
    private func createNotificationTopOverlay(color: UIColor) -> CWStatusBarNotification {
        let notification = CWStatusBarNotification()
        notification.notificationAnimationType = .overlay
        notification.notificationAnimationInStyle = .top
        notification.notificationLabelBackgroundColor = color
        return notification
    }
    
    func showCustomStatusBarNeutral(text: String) {
        showCustomStatusBar(text: text, color: UIColor.blueTraverColor)
    }
    
    func showCustomStatusBarError(text: String) {
        showCustomStatusBar(text: text, color: UIColor.red)
    }
}
