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
import Popover
import Photos

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
                    OperationQueue.main.addOperation {
                        self.refreshOwnerStatus()
                    }
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
                    OperationQueue.main.addOperation {
                        self.refreshOwnerStatus()
                    }
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
        
        if let split = self.splitViewController {
            let detailVC = split.viewControllers[split.viewControllers.endIndex - 1]
            detailVC.childViewControllers[0].navigationController?.pushViewController(recordController, animated: true)
        }
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
    
    func openPhotosListController(ownerID: String, title: String, type: String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PhotosListController") as! PhotosListController
        
        controller.ownerID = ownerID
        controller.type = type
        controller.title = title
        
        if type == "photos" {
            controller.selectIndex = 0
        } else if type == "albums" {
            controller.selectIndex = 1
        }
        
        let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
        detailVC.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
    }
    
    func openAlbumController(ownerID: String, albumID: String, title: String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PhotosListController") as! PhotosListController
        
        controller.ownerID = ownerID
        controller.albumID = albumID
        controller.type = "album"
        controller.title = title
        
        let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
        detailVC.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
    }
    
    func openTopicController(groupID: String, topicID: String, title: String, delegate: UIViewController) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "TopicController") as! TopicController
        
        controller.groupID = groupID
        controller.topicID = topicID
        controller.title = title
        controller.delegate = delegate
        
        if let split = self.splitViewController {
            let detail = split.viewControllers[split.viewControllers.endIndex - 1]
            controller.width = detail.view.bounds.width
            detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openAddNewTopicController(groupID: String, title: String) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "AddNewTopicController") as! AddNewTopicController
        
        controller.groupID = groupID
        controller.title = title
        controller.delegate = self
        
        if let split = self.splitViewController {
            let detail = split.viewControllers[split.viewControllers.endIndex - 1]
            controller.width = detail.view.bounds.width
            detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openNewRecordController(ownerID: String, mode: Mode, title: String, record: Record? = nil) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewRecordController") as! NewRecordController
        
        controller.ownerID = ownerID
        controller.mode = mode
        controller.title = title
        
        controller.delegate = self
        
        if mode == .edit, let record = record {
            controller.record = record
        }
        
        if let split = self.splitViewController {
            let detail = split.viewControllers[split.viewControllers.endIndex - 1]
            controller.width = detail.view.bounds.width
            detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openDialogController(ownerID: String, startID: Int, source: DialogSource = .all) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "DialogController") as! DialogController
        
        controller.userID = ownerID
        controller.startMessageID = startID
        controller.source = source
        controller.delegate = self
        
        if let split = self.splitViewController {
            let detail = split.viewControllers[split.viewControllers.endIndex - 1]
            controller.width = detail.view.bounds.width
            detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func openDialogsController() {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 32.0,
            kWindowWidth: 400,
            kTitleFont: UIFont(name: "Verdana-Bold", size: 14)!,
            kTextFont: UIFont(name: "Verdana", size: 15)!,
            kButtonFont: UIFont(name: "Verdana", size: 16)!,
            showCloseButton: false,
            showCircularIcon: true
        )
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Да, хочу перейти") {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "DialogsController") as! DialogsController
            
            if let split = self.splitViewController {
                let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
            }
        }
        
        alertView.addButton("Нет, я передумал") {}
        
        alertView.showWarning("Подтверждение!", subTitle: "Данное действие изменит ваш статус в сети!\n\nВы действительно хотите перейти в раздел «Сообщения»?")
    }
    
    func updateAppCounters() {
        if let splitVC = self.navigationController?.splitViewController, let detailVC = splitVC.viewControllers[0].childViewControllers[0] as? MenuViewController {
            detailVC.getUserInfo()
        }
    }
    
    func refreshOwnerStatus() {
        if let splitVC = self.navigationController?.splitViewController, let detailVC = splitVC.viewControllers[0].childViewControllers[0] as? MenuViewController {
            detailVC.refreshUserInfo()
        }
    }
    
    func openBrowserController(url: String) {
        
        let res = checkVKLink(url: url)
        
        switch res {
        case 0:
            break
        case 1:
            self.openBrowserControllerNoCheck(url: url)
        case 2:
            let alertController = UIAlertController(title: "внутренняя ссылка ВКонтакте:", message: url, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action1 = UIAlertAction(title: "Открыть ссылку", style: .destructive){ action in
                
                self.openBrowserControllerNoCheck(url: url)
            }
            alertController.addAction(action1)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY - 100, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            present(alertController, animated: true)
        case 3:
            if let stringURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let validURL = URL(string: stringURL) {
                
                UIApplication.shared.open(validURL, options: [:])
            }
        default:
            break
        }
    }
    
    func openBrowserControllerNoCheck(url: String) {
        
        if let url1 = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            guard URL(string: url1) != nil else {
                showErrorMessage(title: "Ошибка!", msg: "Некорректная ссылка:\n\(url1)")
                return
            }
            
            var validURL = url1
            if !url1.containsIgnoringCase(find: "http") && !url1.containsIgnoringCase(find: "https") {
                validURL = "http://\(url1)"
            }
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "BrowserController") as! BrowserController
            
            controller.path = "\(validURL)"
            
            let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
            detailVC.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
        } else {
            showErrorMessage(title: "Ошибка!", msg: "Некорректная ссылка:\n\(url)")
        }
    }
    
    func checkVKLink(url: String) -> Int {
        
        if url.containsIgnoringCase(find: "vk.com") || url.containsIgnoringCase(find: "vk.cc") {
            
            var res = 1
            
            var str1 = url.replacingOccurrences(of: "https://vk.com/", with: "")
            str1 = str1.replacingOccurrences(of: "https://m.vk.com/", with: "")
            str1 = str1.replacingOccurrences(of: "http://vk.com/", with: "")
            str1 = str1.replacingOccurrences(of: "http://m.vk.com/", with: "")
            str1 = str1.replacingOccurrences(of: "m.vk.com/", with: "")
            str1 = str1.replacingOccurrences(of: "vk.com/", with: "")
            let str2 = str1.components(separatedBy: "=")
            if str2.count > 1 {
                str1 = str2[1]
            }
            
            var type = str1.replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression, range: nil)
            type = type.replacingOccurrences(of: "_", with: "", options: .regularExpression, range: nil)
            type = type.replacingOccurrences(of: "-", with: "", options: .regularExpression, range: nil)
            
            
            
            if type == "id" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 1 {
                    if let ownerID = Int(accs[0]) {
                        openProfileController(id: ownerID, name: "")
                    }
                }
                
                res = 0
            } else if type == "club" || type == "event" || type == "public" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 1 {
                    if let ownerID = Int(accs[0]) {
                        openProfileController(id: -1 * abs(ownerID), name: "")
                    }
                }
                
                res = 0
            } else if type == "wall" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 2 {
                    if let ownerID = Int(accs[0]), let postID = Int(accs[1]) {
                        openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
                    }
                }
                
                res = 0
            } else if type == "photo" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 2 {
                    if let ownerID = Int(accs[0]), let photoID = Int(accs[1]) {
                        openWallRecord(ownerID: ownerID, postID: photoID, accessKey: "", type: "photo")
                    }
                }
                
                res = 0
            } else if type == "video" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 2 {
                    if let ownerID = Int(accs[0]), let videoID = Int(accs[1]) {
                        openVideoController(ownerID: "\(ownerID)", vid: "\(videoID)", accessKey: "", title: "")
                    }
                }
                
                res = 0
            } /*else if type == "myownlinkchat" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 3 {
                    if let chatID = Int(accs[2]) {
                        let url = "/method/messages.getHistory"
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "offset": "0",
                            "count": "1",
                            "user_id": "\(2000000000 + chatID)",
                            "start_message_id": "-1",
                            "v": vkSingleton.shared.version
                        ]
                        
                        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                        OperationQueue().addOperation(getServerDataOperation)
                        
                        let parseDialog = ParseDialogHistory()
                        parseDialog.completionBlock = {
                            var startID = parseDialog.inRead
                            if parseDialog.outRead > startID {
                                startID = parseDialog.outRead
                            }
                            OperationQueue.main.addOperation {
                                self.openDialogController(userID: "\(2000000000 + chatID)", chatID: "\(chatID)", startID: startID, attachment: "", messIDs: [], image: nil)
                            }
                        }
                        parseDialog.addDependency(getServerDataOperation)
                        OperationQueue().addOperation(parseDialog)
                    }
                }
                
                res = 0
            }*/ else if type == "topic" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 2 {
                    if let groupID = Int(accs[0]), let topicID = Int(accs[1]) {
                        openTopicController(groupID: "\(abs(groupID))", topicID: "\(topicID)", title: "", delegate: self)
                    }
                }
                
                res = 0
            } else if type == "album" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 2 {
                    if let ownerID = Int(accs[0]), let albumID = Int(accs[1]) {
                        openAlbumController(ownerID: "\(ownerID)", albumID: "\(albumID)", title: "")
                    }
                }
                
                res = 0
            } else if type == "albums" {
                
                var accs = str1.components(separatedBy: "_")
                for index in 0...accs.count-1 {
                    accs[index] = accs[index].replacingOccurrences(of: "[A-Z,a-z,А-Я,а-я]", with: "", options: .regularExpression, range: nil)
                }
                if accs.count == 1 {
                    if let ownerID = Int(accs[0]) {
                        openPhotosListController(ownerID: "\(ownerID)", title: "", type: "albums")
                    }
                }
                
                res = 0
                /*} else if str1.hasPrefix("@") {
                 var accs = str1.components(separatedBy: "-")
                 
                 if accs.count > 0 {
                 if let ownerID = Int(accs[0].replacingOccurrences(of: "@", with: "")), ownerID > 0 {
                 openProfileController(id: ownerID, name: "")
                 }
                 }
                 
                 res = 0*/
            } else if str2.count == 1 {
                let url1 = "/method/utils.resolveScreenName"
                let parameters1 = [
                    "access_token": vkSingleton.shared.accessToken,
                    "screen_name": "\(str2[0])",
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url1, parameters: parameters1)
                
                res = 0
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    let json = try! JSON(data: data)
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        let typeObj = json["response"]["type"].stringValue
                        let ownerID = json["response"]["object_id"].intValue
                        
                        if typeObj == "user" {
                            OperationQueue.main.addOperation {
                                self.openProfileController(id: ownerID, name: "")
                            }
                        }
                        
                        if typeObj == "group" {
                            OperationQueue.main.addOperation {
                                self.openProfileController(id: -1 * ownerID, name: "")
                            }
                        }
                        
                        if typeObj == "application" || typeObj == "" {
                            if AppConfig.shared.setOfflineStatus {
                                res = 2
                            } else {
                                res = 1
                            }
                        }
                    }
                }
                OperationQueue().addOperation(request)
            }
            
            
            if res == 1 && AppConfig.shared.setOfflineStatus {
                res = 2
            }
            
            return res
        } else if url.containsIgnoringCase(find: "itunes.apple.com") {
            
            return 3
        }
        
        return 1
    }
    
    func setCommentFromGroupID(id: Int, controller: UIViewController) {
        
        if id == 0 {
            if let user = vkSingleton.shared.myProfile {
                let getCacheImage = GetCacheImage(url: user.maxPhotoURL, lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    if let avatarImage = getCacheImage.outputImage {
                        OperationQueue.main.addOperation {
                            if let vc = controller as? RecordController {
                                vc.commentView.fromGroupImage = avatarImage
                                vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                            } else if let vc = controller as? VideoController {
                                vc.commentView.fromGroupImage = avatarImage
                                vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                            } else if let vc = controller as? TopicController {
                                vc.commentView.fromGroupImage = avatarImage
                                vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                            }/* else if let vc = controller as? DialogController {
                                vc.commentView.fromGroupImage = avatarImage
                            }*/
                        }
                    }
                }
                OperationQueue().addOperation(getCacheImage)
            }
        } else {
            let url = "/method/groups.getById"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "group_id": "\(abs(id))",
                "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed,can_message,contacts",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            OperationQueue().addOperation(getServerDataOperation)
            
            let parseGroupProfile = ParseGroupProfile()
            parseGroupProfile.completionBlock = {
                if parseGroupProfile.outputData.count > 0 {
                    let group = parseGroupProfile.outputData[0]
                    
                    let getCacheImage = GetCacheImage(url: group.photo50, lifeTime: .avatarImage)
                    getCacheImage.completionBlock = {
                        OperationQueue.main.addOperation {
                            
                            if let vc = controller as? RecordController {
                                vc.commentView.fromGroupImage = getCacheImage.outputImage
                                vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                            } else if let vc = controller as? VideoController {
                                vc.commentView.fromGroupImage = getCacheImage.outputImage
                                vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                            } else if let vc = controller as? TopicController {
                                vc.commentView.fromGroupImage = getCacheImage.outputImage
                                vc.commentView.fromGroupButton.addTarget(self, action: #selector(vc.tapFromGroupButton(sender:)), for: .touchUpInside)
                            }/* else if let vc = controller as? GroupDialogController {
                                vc.commentView.fromGroupImage = getCacheImage.outputImage
                            }*/
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                }
            }
            parseGroupProfile.addDependency(getServerDataOperation)
            OperationQueue().addOperation(parseGroupProfile)
        }
    }
    
    func actionFromGroupButton(fromView: UIView) {
        var popover: Popover!
        let popoverOptions: [PopoverOption] = [
            .type(.up),
            .cornerRadius(6),
            .color(UIColor.white),
            .blackOverlayColor(UIColor.gray.withAlphaComponent(0.75))
        ]
        
        let maxWidth = self.view.frame.width - 40
        
        let textFont = UIFont(name: "Verdana", size: 14)!
        let headFont = UIFont(name: "Verdana", size: 15)!
        
        let view = UIView()
        
        var height: CGFloat = 10
        
        let titleLabel = UILabel()
        titleLabel.text = "Отправлять комментарии:"
        titleLabel.font = headFont
        titleLabel.textAlignment = .center
        titleLabel.frame = CGRect(x: 20, y: height, width: maxWidth - 40, height: 20)
        view.addSubview(titleLabel)
        
        height += 25
        
        if let user = vkSingleton.shared.myProfile {
            let ownLabel = UILabel()
            ownLabel.text = "от своего имени «\(user.firstName) \(user.lastName)»"
            
            let fullString = "от своего имени «\(user.firstName) \(user.lastName)»"
            let rangeOfColoredString = (fullString as NSString).range(of: "«\(user.firstName) \(user.lastName)»")
            let attributedString = NSMutableAttributedString(string: fullString)
            
            if vkSingleton.shared.commentFromGroup == 0 {
                attributedString.setAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], range: rangeOfColoredString)
            } else {
                attributedString.setAttributes([NSAttributedStringKey.foregroundColor: ownLabel.tintColor], range: rangeOfColoredString)
            }
            
            ownLabel.attributedText = attributedString
            
            if vkSingleton.shared.commentFromGroup != 0 {
                let tap = UITapGestureRecognizer()
                tap.numberOfTapsRequired = 1
                tap.add {
                    popover.dismiss()
                    self.setCommentFromGroupID(id: 0, controller: self)
                    vkSingleton.shared.commentFromGroup = 0
                }
                ownLabel.isUserInteractionEnabled = true
                ownLabel.addGestureRecognizer(tap)
            }
            
            ownLabel.font = textFont
            ownLabel.textAlignment = .left
            ownLabel.clipsToBounds = true
            ownLabel.frame = CGRect(x: 20, y: height, width: maxWidth - 80, height: 30)
            view.addSubview(ownLabel)
            
            let avatar = UIImageView()
            let getCacheImage = GetCacheImage(url: user.maxPhotoURL, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                if let avatarImage = getCacheImage.outputImage {
                    OperationQueue.main.addOperation {
                        avatar.image = avatarImage
                    }
                }
            }
            OperationQueue().addOperation(getCacheImage)
            avatar.layer.cornerRadius = 15
            avatar.layer.borderColor = UIColor.gray.cgColor
            avatar.layer.borderWidth = 0.6
            avatar.clipsToBounds = true
            avatar.frame = CGRect(x: maxWidth - 50, y: height, width: 30, height: 30)
            view.addSubview(avatar)
            
            if vkSingleton.shared.commentFromGroup != 0 {
                let tap = UITapGestureRecognizer()
                tap.numberOfTapsRequired = 1
                tap.add {
                    popover.dismiss()
                    self.setCommentFromGroupID(id: 0, controller: self)
                    vkSingleton.shared.commentFromGroup = 0
                }
                avatar.isUserInteractionEnabled = true
                avatar.addGestureRecognizer(tap)
            }
            
            height += 35
        }
        
        let url = "/method/groups.get"
        let parameters = [
            "user_id": vkSingleton.shared.userID,
            "access_token": vkSingleton.shared.accessToken,
            "filter": "admin",
            "extended": "1",
            "fields": "name,cover,members_count,type,is_closed,deactivated,invited_by",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        let parseGroups = ParseGroupList()
        parseGroups.completionBlock = {
            var groups = parseGroups.outputData
            
            if let vc = self as? VideoController {
                groups.removeAll(keepingCapacity: false)
                if let ownerID = Int(vc.ownerID), ownerID < 0 {
                    for group in parseGroups.outputData {
                        if "\(abs(ownerID))" == group.gid {
                            groups.append(group)
                        }
                    }
                }
            }
            
            if let vc = self as? TopicController {
                groups.removeAll(keepingCapacity: false)
                if let ownerID = Int(vc.groupID) {
                    for group in parseGroups.outputData {
                        if "\(ownerID)" == group.gid {
                            groups.append(group)
                        }
                    }
                }
            }
            
            if groups.count > 0 {
                OperationQueue.main.addOperation {
                    for group in groups {
                        let ownLabel = UILabel()
                        ownLabel.text = "от имени сообщества «\(group.name)»"
                        
                        if let gid = Int(group.gid) {
                            let fullString = "от имени сообщества «\(group.name)»"
                            let rangeOfColoredString = (fullString as NSString).range(of: "«\(group.name)»")
                            let attributedString = NSMutableAttributedString(string: fullString)
                            
                            if vkSingleton.shared.commentFromGroup == gid {
                                attributedString.setAttributes([NSAttributedStringKey.foregroundColor: UIColor.red], range: rangeOfColoredString)
                            } else {
                                attributedString.setAttributes([NSAttributedStringKey.foregroundColor: ownLabel.tintColor], range: rangeOfColoredString)
                            }
                            
                            ownLabel.attributedText = attributedString
                            
                            if vkSingleton.shared.commentFromGroup != gid {
                                let tap = UITapGestureRecognizer()
                                tap.numberOfTapsRequired = 1
                                tap.add {
                                    popover.dismiss()
                                    self.setCommentFromGroupID(id: gid, controller: self)
                                    vkSingleton.shared.commentFromGroup = gid
                                }
                                ownLabel.isUserInteractionEnabled = true
                                ownLabel.addGestureRecognizer(tap)
                            }
                        }
                        
                        ownLabel.font = textFont
                        ownLabel.textAlignment = .left
                        ownLabel.clipsToBounds = true
                        ownLabel.frame = CGRect(x: 20, y: height, width: maxWidth - 80, height: 30)
                        view.addSubview(ownLabel)
                        
                        let avatar2 = UIImageView()
                        let getCacheImage = GetCacheImage(url: group.coverURL, lifeTime: .avatarImage)
                        getCacheImage.completionBlock = {
                            OperationQueue.main.addOperation {
                                avatar2.image = getCacheImage.outputImage
                            }
                        }
                        OperationQueue().addOperation(getCacheImage)
                        avatar2.layer.cornerRadius = 15
                        avatar2.layer.borderColor = UIColor.gray.cgColor
                        avatar2.layer.borderWidth = 0.6
                        avatar2.clipsToBounds = true
                        avatar2.frame = CGRect(x: maxWidth - 50, y: height, width: 30, height: 30)
                        view.addSubview(avatar2)
                        
                        if let gid = Int(group.gid) {
                            if vkSingleton.shared.commentFromGroup != gid {
                                let tap = UITapGestureRecognizer()
                                tap.numberOfTapsRequired = 1
                                tap.add {
                                    popover.dismiss()
                                    self.setCommentFromGroupID(id: gid, controller: self)
                                    vkSingleton.shared.commentFromGroup = gid
                                }
                                avatar2.isUserInteractionEnabled = true
                                avatar2.addGestureRecognizer(tap)
                            }
                        }
                        
                        height += 35
                    }
                    
                    height += 5
                    view.frame = CGRect(x: 0, y: 0, width: maxWidth, height: height)
                    
                    
                    let point = CGPoint(x: fromView.frame.midX, y: self.view.frame.height - 12 - fromView.frame.height)
                    
                    popover = Popover(options: popoverOptions)
                    popover.show(view, point: point, inView: self.view)
                }
            }
        }
        parseGroups.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseGroups)
    }
    
    func saveGifToDevice(url: URL) {
        if let data = try? Data(contentsOf: url) {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
            })
            
            OperationQueue.main.addOperation {
                ViewControllerUtils().hideActivityIndicator()
                self.showSuccessMessage(title: "Сохранение на устройство", msg: "GIF успешно сохранена на ваше устройство.")
            }
            
        } else {
            OperationQueue.main.addOperation {
                ViewControllerUtils().hideActivityIndicator()
                self.showErrorMessage(title: "Сохранение на устройство", msg: "Возникла неизвестная ошибка при сохранении GIF на устройство")
            }
        }
    }
}


