//
//  AppDelegate.swift
//  flashcards
//
//  Created by Bryan Workman on 7/15/20.
//  Copyright © 2020 Bryan Workman. All rights reserved.
//

import UIKit
//import CloudKit
//import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
} //End of class







/*  //Notification Alert -- check for user -- present alert -- ask for notifications

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        checkAccountStatus { (success) in

            let fetchedUserStatment = success ? "Successfully retrieved a logged in user" : "Failed to retrieve a logged in user"

            print(fetchedUserStatment)
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in

            if let error = error {
                print("There was an error in \(#function) ; \(error)  ; \(error.localizedDescription)")
                return
            }
            success ? print("Successfully authorized to send push notifications") : print("DENIED, Can't send this person notificiations")
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        return true
    }

    func checkAccountStatus(completion: @escaping (Bool) -> Void) {

        CKContainer.default().accountStatus { (status, error) in

            if let error = error {
                print("Error checking accountStatus \(error) \(error.localizedDescription)")
                return completion(false)
            }
            else {
                DispatchQueue.main.async {

                    let tabBarController = self.window?.rootViewController

                    let errrorText = "Sign into iCloud in Settings"

                    switch status {
                    case .available:
                        completion(true);

                    case .noAccount:
                        tabBarController?.presentSimpleAlertWith(title: errrorText, message: "No account found")
                        completion(false)

                    case .couldNotDetermine:
                        tabBarController?.presentSimpleAlertWith(title: errrorText, message: "There was an unknown error fetching your iCloud Account")
                        completion(false)

                    case .restricted:
                        tabBarController?.presentSimpleAlertWith(title: errrorText, message: "Your iCloud account is restricted")
                        completion(false)

                    default:
                        tabBarController?.presentSimpleAlertWith(title: errrorText, message: "Unknown Error")
                    }
                }
            }
        }
    }
*/



