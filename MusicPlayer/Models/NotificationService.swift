//
//  NotificationService.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 31.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UserNotifications

final class NotificationService: NSObject {
    
    static let main = NotificationService()
    
    private override init() {
        super.init()
    }
    
    func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound]
        center.requestAuthorization(options: options) { granted, error in }
    }
    
    func presentNotificationForDownloadedSong(with title: String, url: URL) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                return
            }
            let content = UNMutableNotificationContent()
            content.body = "Song \"\(title)\" has  been downloaded"
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            
            let id = UUID().uuidString
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            
            center.add(request)
        }
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}
