//
//  NotificationCenterManager.swift
//  Traver
//
//  Created by Natalia Nikitina on 7/10/17.
//  Copyright © 2017 Natalia Nikitina. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationCenterManager {
    
    static let shared = NotificationCenterManager()
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    private func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
}
