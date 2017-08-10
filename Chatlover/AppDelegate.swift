//
//  AppDelegate.swift
//  Chatlover
//
//  Created by Grzegorz Hudziak on 10/08/2017.
//  Copyright © 2017 Applover. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        // Register Push notifications
        registerForPushNotifications(application: application)
        
        return true
    }
    
    //==========================
    // START PUSH NOTIFICATIONS
    //==========================
    
    // MARK: - Register notifications
    func registerForPushNotifications(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound], completionHandler: { _ in })
        application.registerForRemoteNotifications()
    }
    
    // MARK: - Remote notifications did register
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
        Messaging.messaging().apnsToken = deviceToken
        print("Device Token:", deviceTokenString)
    }
    
    // MARK: - Remote notifications did fail
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
    
    // MARK: - Receive notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
        Messaging.messaging().appDidReceiveMessage(userInfo)
        debugPrint(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    //========================
    // END PUSH NOTIFICATIONS
    //========================
}

