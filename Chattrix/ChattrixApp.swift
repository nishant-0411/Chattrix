//
//  ChattrixApp.swift
//  Chattrix
//
//  Created by Nishant on 10/06/25.
//


import FirebaseAuth
import SwiftUI
import Firebase
import GoogleSignIn
import UIKit
import UserNotifications
import FirebaseCore

@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
    WindowGroup {
        //AccountCreation(show: .constant(true))
        ContentView()
            .onOpenURL { url in
                _ = Auth.auth().canHandle(url)
            }
    }
  }
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        // 🔔 Request Push Notification Permission
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // 🔄 Firebase Phone Auth Notification Handler
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

//        if Auth.auth().canHandleNotification(userInfo) {
//            completionHandler(.noData)
//            return
//        }

        completionHandler(.newData)
    }
}

