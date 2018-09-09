//
//  AppDelegate.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import UserNotifications
import SwiftMessages
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        registerForPushNotifications()
        application.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = self
        
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            vkSingleton.shared.pushInfo = userInfo
        }
        
        StoreReviewHelper.incrementAppOpenedCount()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        if AppConfig.shared.passwordOn {
            if let currentVC = topViewControllerWithRootViewController(rootViewController: window?.rootViewController), !(currentVC is PasswordController) {
                let vc = currentVC.storyboard?.instantiateViewController(withIdentifier: "PasswordController") as! PasswordController
                vc.state = "login"
                currentVC.present(vc, animated: true)
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            OperationQueue.main.addOperation {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        vkSingleton.shared.deviceToken = token
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    var orientationLock = UIInterfaceOrientationMask.landscape

    var myOrientation: UIInterfaceOrientationMask = .landscape
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return myOrientation
    }
    
    func topViewControllerWithRootViewController(rootViewController: UIViewController!) -> UIViewController! {
        
        if rootViewController is UITabBarController {
            let tabbarController =  rootViewController as! UITabBarController
            return self.topViewControllerWithRootViewController(rootViewController: tabbarController.selectedViewController)
        } else if rootViewController is UINavigationController {
            let navigationController = rootViewController as! UINavigationController
            return self.topViewControllerWithRootViewController(rootViewController: navigationController.visibleViewController)
        } else if let split = rootViewController as? UISplitViewController {
            return split.viewControllers[split.viewControllers.endIndex - 1]
        } else if rootViewController.presentedViewController != nil {
            let controller = rootViewController.presentedViewController
            
            return self.topViewControllerWithRootViewController(rootViewController: controller)
        } else {
            return rootViewController
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        
        if let currentVC = topViewControllerWithRootViewController(rootViewController: window?.rootViewController), !(currentVC is PasswordController) {
            
            if currentVC is UIAlertController {
                currentVC.dismiss(animated: false) { () -> Void in
                    if let currentVC2 = self.topViewControllerWithRootViewController(rootViewController: self.window?.rootViewController) {
                        self.tapPushNotification(userInfo, controller: currentVC2)
                    }
                }
            } else {
                self.tapPushNotification(userInfo, controller: currentVC)
            }
        }
        
        completionHandler()
    }
    
    func tapPushNotification(_ userInfo: [AnyHashable: Any], controller: UIViewController) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        SwiftMessages.hideAll()
        if let type = (userInfo["data"] as AnyObject).object(forKey: "category") as? String {
            
            if type == "comment" {
                if let place = (userInfo["data"] as AnyObject).object(forKey: "place") as? String {
                    var placeType = place.replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression, range: nil)
                    placeType = placeType.replacingOccurrences(of: "_", with: "", options: .regularExpression, range: nil)
                    
                    if placeType == "wall" {
                        let digits = place.replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                        let comp = digits.components(separatedBy: "_")
                        
                        if comp.count > 1, let ownerID = Int(comp[0]), let postID = Int(comp[1]) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
                        }
                    } else if placeType == "photo" {
                        let digits = place.replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                        let comp = digits.components(separatedBy: "_")
                        
                        if comp.count > 1, let ownerID = Int(comp[0]), let postID = Int(comp[1]) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "photo")
                        }
                    } else if placeType == "video" {
                        let digits = place.replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                        let comp = digits.components(separatedBy: "_")
                        
                        if comp.count > 1 {
                            let ownerID = comp[0]
                            let videoID = comp[1]
                            
                            controller.openVideoController(ownerID: ownerID, vid: videoID, accessKey: "", title: "Видеозапись")
                        }
                    } else {
                        controller.openNotificationController()
                    }
                } else {
                    controller.openNotificationController()
                }
            } else if type == "like" {
                if let userID = (userInfo["data"] as AnyObject).object(forKey: "owner_id") as? String, let itemID = (userInfo["data"] as AnyObject).object(forKey: "item_id") as? String, let likeType = (userInfo["data"] as AnyObject).object(forKey: "like_type") as? String {
                    if likeType == "post" || likeType == "comment"{
                        if let ownerID = Int(userID), let postID = Int(itemID) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
                        }
                    } else if likeType == "photo" || likeType == "photo_comment" {
                        if let ownerID = Int(userID), let photoID = Int(itemID) {
                            
                            controller.openWallRecord(ownerID: ownerID, postID: photoID, accessKey: "", type: "photo")
                        }
                    } else if likeType == "video" || likeType == "video_comment"{
                        controller.openVideoController(ownerID: userID, vid: itemID, accessKey: "", title: "Видеозапись")
                    } else if likeType == "topic_comment"{
                        controller.openTopicController(groupID: userID, topicID: itemID, title: "", delegate: controller)
                    } else {
                        controller.openNotificationController()
                    }
                } else {
                    controller.openNotificationController()
                }
            } else if type == "msg" {
                if let pushID = (userInfo["data"] as AnyObject).object(forKey: "push_id") as? String {
                    let comp = pushID.components(separatedBy: "_")
                    if comp.count == 3, let startID = Int(comp[2]) {
                        let userID = comp[1]
                        
                        if userID != vkSingleton.shared.userID {
                            controller.openDialogController(ownerID: "\(userID)", startID: startID)
                        }
                    }
                } else {
                    controller.openNotificationController()
                }
            } else if type == "new_post" {
                if let place = (userInfo["data"] as AnyObject).object(forKey: "place") as? String {
                    let digits = place.replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                    let comp = digits.components(separatedBy: "_")
                    
                    if comp.count > 1, let ownerID = Int(comp[0]), let postID = Int(comp[1]) {
                        print(place)
                        
                        controller.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
                    }
                } else {
                    controller.openNotificationController()
                }
            } else if type == "show_message" {
                
            } else if type == "birthday" {
                controller.openUsersController(uid: vkSingleton.shared.userID, title: "Мои друзья", type: "friends")
            } else if type == "chat" {
                if let pushID = (userInfo["data"] as AnyObject).object(forKey: "push_id") as? String {
                    let comp = pushID.components(separatedBy: "_")
                    if comp.count == 3, let startID = Int(comp[2]), let chatID = Int(comp[1]) {
                        let userID = comp[1]
                        
                        if userID != vkSingleton.shared.userID {
                            controller.openDialogController(ownerID: "\(userID)", chatID: chatID - 2000000000, startID: startID)
                        }
                    }
                } else {
                    controller.openNotificationController()
                }
            } else if type == "friend" {
                if let uid = (userInfo["data"] as AnyObject).object(forKey: "uid") as? String, let id = Int(uid) {
                    controller.updateAppCounters()
                    controller.openProfileController(id: id, name: "")
                }
            } else if type == "group_invite" {
                controller.openGroupsListController(uid: vkSingleton.shared.userID, title: "Новые приглашения в сообщества", type: "invites")
            } else {
                controller.openNotificationController()
                if vkSingleton.shared.userID == "357365563" || vkSingleton.shared.userID == "34051891" {
                    controller.showInfoMessage(title: "Push Settings", msg: "category = \"\(type)\"")
                }
            }
        }
    }
}

