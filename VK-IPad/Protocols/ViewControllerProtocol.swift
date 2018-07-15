//
//  ViewControllerProtocol.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import RealmSwift
import SCLAlertView
import SwiftyJSON

protocol ViewControllerProtocol {
    
    func setOfflineStatus(dependence: Operation?)
    
    func showErrorMessage(title: String, msg: String)
    
    func showSuccessMessage(title: String, msg: String)
    
    func showInfoMessage(title: String, msg: String)
    
    func updateAccountInRealm(account: vkAccount)
    
    func deleteAccountFromRealm(userID: Int)
    
    func getAccessTokenFromRealm(userID: Int) -> String
    
    func getNumberOfAccounts() -> Int
}

extension UIViewController: ViewControllerProtocol {
    
    func setOfflineStatus(dependence: Operation?) {
        if AppConfig.shared.setOfflineStatus {
            let url = "/method/account.setOffline"
            let parameters = [ "access_token": vkSingleton.shared.accessToken,
                               "v": vkSingleton.shared.version ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            if let operation = dependence {
                request.addDependency(operation)
            }
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                let result = json["response"].intValue
                
                if result == 1 {
                    print("offline: succesful")
                } else {
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    print("#\(error.errorCode): \(error.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        } else {
            let url = "/method/account.setOnline"
            let parameters = [ "access_token": vkSingleton.shared.accessToken,
                               "v": vkSingleton.shared.version ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            if let operation = dependence {
                request.addDependency(operation)
            }
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                let result = json["response"].intValue
                
                if result == 1 {
                    print("online: succesful")
                } else {
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    print("#\(error.errorCode): \(error.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func showErrorMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: self.view.bounds.width/2 + 100,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("OK", action: {})
            alert.showError(title, subTitle: msg)
        }
    }
    
    func showSuccessMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: self.view.bounds.width/2 + 100,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("OK", action: {})
            alert.showSuccess(title, subTitle: msg)
        }
    }
    
    func showInfoMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: self.view.bounds.width/2 + 100,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("OK", action: {})
            alert.showInfo(title, subTitle: msg)
        }
    }
    
    func updateAccountInRealm(account: vkAccount) {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            
            let realm = try Realm(configuration: config)
            
            //print(realm.configuration.fileURL!)
            
            realm.beginWrite()
            realm.add(account, update: true)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func deleteAccountFromRealm(userID: Int) {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            
            let realm = try Realm(configuration: config)
            
            let account = realm.objects(vkAccount.self).filter("userID == %@", userID)
            
            realm.beginWrite()
            realm.delete(account)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func getAccessTokenFromRealm(userID: Int) -> String {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            
            let realm = try Realm(configuration: config)
            
            let realmAccounts = realm.objects(vkAccount.self).filter("userID == %@", userID)
            
            
            let accounts = Array(realmAccounts)
            if accounts.count > 0 {
                return accounts[0].token
            }
        } catch {
            print(error)
        }
        
        return ""
    }
    
    func getNumberOfAccounts() -> Int {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            
            let realm = try Realm(configuration: config)
            
            let realmAccounts = realm.objects(vkAccount.self)
            let accounts = Array(realmAccounts)
            return accounts.count
        } catch {
            print(error)
        }
        
        return 0
    }
    
    func getTextSize(text: String, font: UIFont, maxWidth: CGFloat) -> CGSize {
        
        let textBlock = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        let width = Double(rect.size.width)
        var height = Double(rect.size.height)
        
        if text == "" {
            height = 0
        }
        return CGSize(width: ceil(width), height: ceil(height))
    }
    
    func openUsersController(uid: String, title: String, type: String) {
        let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
        
        usersController.userID = uid
        usersController.type = type
        usersController.source = ""
        usersController.title = title
        
        let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
        detailVC.childViewControllers[0].navigationController?.pushViewController(usersController, animated: true)
    }
    
    func openNotificationController() {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NotificationController") as! NotificationController
        
        let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
        detailVC.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
    }
    
    func openProfileController(id: Int, name: String) {
        if id > 0 {
            let profileController = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            
            profileController.userID = "\(id)"
            profileController.title = name
            
            let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
            detailVC.childViewControllers[0].navigationController?.pushViewController(profileController, animated: true)
        } else if id < 0 {
            let profileController = self.storyboard?.instantiateViewController(withIdentifier: "GroupProfileViewController") as! GroupProfileViewController
            
            profileController.groupID = abs(id)
            profileController.title = name
            
            let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
            detailVC.childViewControllers[0].navigationController?.pushViewController(profileController, animated: true)
        }
    }
    
    func openGroupsListController(uid: String, title: String, type: String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "GroupsListController") as! GroupsListController
        
        controller.userID = uid
        controller.type = type
        controller.source = ""
        controller.title = title
        
        let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
        detailVC.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
    }
    
    func openPhotoViewController(numPhoto: Int, photos: [Photo]) {
        let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
        
        
        photoViewController.numPhoto = numPhoto
        photoViewController.photos = photos
        
        photoViewController.delegate = self
        
        let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
        detailVC.childViewControllers[0].navigationController?.pushViewController(photoViewController, animated: true)
    }
    
    func openWallRecord(ownerID: Int, postID: Int, accessKey: String, type: String) {
        let recordController = self.storyboard?.instantiateViewController(withIdentifier: "RecordController") as! RecordController
        
        recordController.type = type
        recordController.uid = ownerID
        recordController.pid = postID
        recordController.accessKey = accessKey
        
        recordController.delegate = self
        
        let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
        detailVC.childViewControllers[0].navigationController?.pushViewController(recordController, animated: true)
    }
    
    func openLikesUsersController(likes: [Likes], reposts: [Likes]) {
        let likesController = self.storyboard?.instantiateViewController(withIdentifier: "LikesUsersController") as! LikesUsersController
    
        likesController.likes = likes
        likesController.reposts = reposts
        likesController.title = "Оценили"
        
        let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
        detailVC.childViewControllers[0].navigationController?.pushViewController(likesController, animated: true)
    }
    
    func openVideoListController(ownerID: String, title: String, type: String) {
        let videoController = self.storyboard?.instantiateViewController(withIdentifier: "VideoListController") as! VideoListController
        
        videoController.ownerID = ownerID
        videoController.type = type
        videoController.title = title
        
        let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
        detailVC.childViewControllers[0].navigationController?.pushViewController(videoController, animated: true)
    }
    
    func openVideoController(ownerID: String, vid: String, accessKey: String, title: String) {
        let videoController = self.storyboard?.instantiateViewController(withIdentifier: "VideoController") as! VideoController
        
        videoController.ownerID = ownerID
        videoController.vid = vid
        videoController.accessKey = accessKey
        videoController.title = title
        
        let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
        detailVC.childViewControllers[0].navigationController?.pushViewController(videoController, animated: true)
    }
}


