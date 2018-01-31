//
//  NotificationManager.swift
//  SMARTFile
//
//  Created by Tom Rogers on 26/01/2018.
//  Copyright © 2018 Smartphone Media Group Ltd. All rights reserved.
//

import Foundation
import UserNotifications


class NotificationManager {
    
    static let sharedInstance = NotificationManager()
    
    
    private init() {
        
    }
    
    
    
    func notifyUser () {
    
        let center =  UNUserNotificationCenter.current()
        
        //create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = "SMARTFile"
        content.subtitle = "Update"
        content.body = "Current upload has completed"
        content.sound = UNNotificationSound.default()
        
        //notification trigger can be based on time, calendar or location
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:1.0, repeats: false)
        
        //create request to display
        let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
        
        //add request to notification center
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
    }
    
    
}
