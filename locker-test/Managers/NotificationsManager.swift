//
//  NotificationsManager.swift
//  locker-test
//
//  Created by Danil Bezuglov on 1/8/23.
//

import SwiftUI
import UserNotifications

final class NotificationsManager: ObservableObject {
    @Published private(set) var notifications: [UNNotificationRequest] = []
    @Published private(set) var authorizationStatus: UNAuthorizationStatus?
    
    func reloadAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { isGranted, _ in
            DispatchQueue.main.async {
                self.authorizationStatus = isGranted ? .authorized : .denied
            }
        }
    }
    
    func reloadLocalNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            DispatchQueue.main.async {
                self.notifications = notifications
            }
        }
    }
    
    func deleteNotification(_ i: Int) {
        self.notifications.remove(at: i)
    }
    
    func deleteNotificationIS(_ i: IndexSet) {
        self.notifications.remove(atOffsets: i)
    }
}

