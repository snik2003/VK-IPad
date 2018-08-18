//
//  vkOperationProtocol.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 26.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

protocol VkOperationProtocol {
    
    func unregisterDeviceOnPush()
    
    func registerDeviceOnPush()
    
    func userInFave()
    
    func userInNewsfeed()
    
    func userInBanList()
    
    func groupInFave()
    
    func groupInNewsfeed()
    
    func pinRecord()
    
    func addLinkToFave(object: AnyObject)
}

extension UIViewController: VkOperationProtocol {
    
    func unregisterDeviceOnPush() {
        
        let userDefaults = UserDefaults.standard
        
        var sandbox = 0
        if Config.appConfiguration == .Debug {
            sandbox = 1
        }
        
        let url = "/method/account.unregisterDevice"
        let parameters = [
            //"token": vkSingleton.shared.deviceToken,
            "device_id": "\(UIDevice.current.identifierForVendor!)",
            "sandbox": "\(sandbox)",
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
            ] as [String : Any]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            let result = json["response"].intValue
            
            if result == 1 {
                userDefaults.setValue(false, forKey: "\(vkSingleton.shared.userID)_registerPush")
                print("Device successfully unregistered on Push")
            }  else {
                vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                
                if vkSingleton.shared.errorCode != 0 {
                    self.showErrorMessage(title: "Настройка пуш!", msg: "Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                }
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func registerDeviceOnPush() {
        
        var jsonParam: [String: [String]] = ["":[""]]
        
        if AppConfig.shared.pushNewMessage {
            if AppConfig.shared.showStartMessage {
                jsonParam["msg"] = ["on"]
                jsonParam["chat"] = ["on"]
            } else {
                jsonParam["msg"] = ["on", "no_text"]
                jsonParam["chat"] = ["on", "no_text"]
            }
        } else {
            jsonParam["msg"] = ["off"]
            jsonParam["chat"] = ["off"]
        }
        
        if AppConfig.shared.pushComment {
            jsonParam["comment"] = ["on"]
        } else {
            jsonParam["comment"] = ["off"]
        }
        
        if AppConfig.shared.pushNewFriends {
            jsonParam["friend"] = ["on"]
            jsonParam["friend_accepted"] = ["on"]
            jsonParam["friend_found"] =  ["on"]
            
        } else {
            jsonParam["friend"] = ["off"]
            jsonParam["friend_accepted"] = ["off"]
            jsonParam["friend_found"] =  ["off"]
        }
        
        if AppConfig.shared.pushNots {
            jsonParam["reply"] = ["on"]
            jsonParam["repost"] = ["on"]
            jsonParam["new_post"] = ["on"]
            jsonParam["birthday"] = ["on"]
            jsonParam["gift"] = ["on"]
            jsonParam["live"] = ["on"]
            jsonParam["tag_photo"] = ["on"]
        } else {
            jsonParam["reply"] = ["off"]
            jsonParam["repost"] = ["off"]
            jsonParam["new_post"] = ["off"]
            jsonParam["birthday"] = ["off"]
            jsonParam["gift"] = ["off"]
            jsonParam["live"] = ["off"]
            jsonParam["tag_photo"] = ["off"]
        }
        
        if AppConfig.shared.pushLikes {
            jsonParam["like"] = ["on"]
        } else {
            jsonParam["like"] = ["off"]
        }
        
        if AppConfig.shared.pushMentions {
            jsonParam["mention"] = ["on"]
            jsonParam["chat_mention"] = ["on"]
        } else {
            jsonParam["mention"] = ["off"]
            jsonParam["chat_mention"] = ["off"]
        }
        
        if AppConfig.shared.pushFromGroups {
            jsonParam["group_invite"] = ["on"]
            jsonParam["group_accepted"] = ["on"]
            jsonParam["event_soon"] = ["on"]
            jsonParam["private_group_post"] = ["on"]
            jsonParam["associated_events"] = ["on"]
        } else {
            jsonParam["group_invite"] = ["off"]
            jsonParam["group_accepted"] = ["off"]
            jsonParam["event_soon"] = ["off"]
            jsonParam["private_group_post"] = ["off"]
            jsonParam["associated_events"] = ["off"]
        }
        
        if AppConfig.shared.pushNewPosts {
            jsonParam["wall_post"] = ["on"]
            jsonParam["wall_publish"] = ["on"]
            jsonParam["story_reply"] = ["on"]
            jsonParam["interest_post"] = ["on"]
        } else {
            jsonParam["wall_post"] = ["off"]
            jsonParam["wall_publish"] = ["off"]
            jsonParam["story_reply"] = ["off"]
            jsonParam["interest_post"] = ["off"]
        }
        
        jsonParam["sdk_open"] = ["on"]
        jsonParam["app_request"] = ["on"]
        jsonParam["call"] = ["on"]
        jsonParam["money"] = ["on"]
        
        var sandbox = 0
        if Config.appConfiguration == .Debug {
            sandbox = 1
        }
        
        let url = "/method/account.registerDevice"
        let parameters = [
            "token": vkSingleton.shared.deviceToken,
            "device_model": UIDevice.current.localizedModel,
            "device_id": "\(UIDevice.current.identifierForVendor!)",
            "system_version": UIDevice.current.systemVersion,
            "sandbox": "\(sandbox)",
            "settings": JSON(jsonParam),
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
            ] as [String : Any]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            let result = json["response"].intValue
            
            if result == 1 {
                print("Device successfully registered on Push")
                self.getPushSettings()
            }  else {
                vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                
                if vkSingleton.shared.errorCode != 0 {
                    self.showErrorMessage(title: "Настройка пуш!", msg: "Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                }
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func getPushSettings() {
        let opq = OperationQueue()
        
        let url = "/method/account.getPushSettings"
        let parameters = [
            "device_id": "\(UIDevice.current.identifierForVendor!)",
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
            ]  as [String : Any]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(request)
        
        let parsePush = ParsePushSettings()
        parsePush.addDependency(request)
        parsePush.completionBlock = {
            if vkSingleton.shared.errorCode == 0 {
                if parsePush.settings.disabled == 1 {
                    print("Пуш-уведомления отключены")
                    //AppConfig.shared.pushNotificationsOn = false
                    //UserDefaults.standard.set(false, forKey: "\(vkSingleton.shared.userID)_pushNotificationsOn")
                } else {
                    print("message: \"\(parsePush.settings.msg)\"")
                    print("comment: \"\(parsePush.settings.comment)\"")
                    print("friend: \"\(parsePush.settings.friend)\"")
                    print("reply: \"\(parsePush.settings.reply)\"")
                    print("like: \"\(parsePush.settings.like)\"")
                    print("mention: \"\(parsePush.settings.mention)\"")
                    print("group_accepted: \"\(parsePush.settings.groupAccepted)\"")
                    print("new_posts: \"\(parsePush.settings.wallPost)\"")
                }
            } else {
                self.showErrorMessage(title: "Получение настроек Push", msg: "Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
            }
        }
        opq.addOperation(parsePush)
    }
    
    func userInFave() {
        
        if let controller = self as? ProfileViewController, controller.userProfile.count > 0 {
            
            let user = controller.userProfile[0]
            
            var url = ""
            var parameters: Parameters = [:]
            var successText = ""
            
            if user.isFavorite == 1 {
                url = "/method/fave.removeUser"
                parameters = [
                    "user_id": user.uid,
                    "access_token": vkSingleton.shared.accessToken,
                    "v": vkSingleton.shared.version
                ]
                
                if user.sex == 1 {
                    successText = "\n\(user.firstName) \(user.lastName) успешно удалена из «Избранное».\n"
                } else {
                    successText = "\n\(user.firstName) \(user.lastName) успешно удален из «Избранное».\n"
                }
            } else {
                url = "/method/fave.addUser"
                parameters = [
                    "user_id": user.uid,
                    "access_token": vkSingleton.shared.accessToken,
                    "v": vkSingleton.shared.version
                ]
                
                if user.sex == 1 {
                    successText = "\n\(user.firstName) \(user.lastName) успешно добавлена в «Избранное».\n"
                } else {
                    successText = "\n\(user.firstName) \(user.lastName) успешно добавлен в «Избранное».\n"
                }
            }
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                let result = json["response"].intValue
                
                if result == 1 {
                    if user.isFavorite == 1 {
                        controller.userProfile[0].isFavorite = 0
                    } else {
                        controller.userProfile[0].isFavorite = 1
                    }
                    
                    OperationQueue.main.addOperation {
                        
                    }
                    self.showSuccessMessage(title: "Избранные пользователи", msg: successText)
                } else {
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    self.showErrorMessage(title: "Избранные пользователи", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func userInNewsfeed() {
        if let controller = self as? ProfileViewController, controller.userProfile.count > 0 {
            
            let user = controller.userProfile[0]
            
            var url = ""
            var parameters: Parameters = [:]
            var successText = ""
            
            if user.isHiddenFromFeed == 0 {
                url = "/method/newsfeed.addBan"
                parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "user_ids": user.uid,
                    "v": vkSingleton.shared.version
                ]
                
                successText = "Новости \(user.firstNameGen) \(user.lastNameGen) больше не будут показываться в вашей ленте новостей."
            } else {
                url = "/method/newsfeed.deleteBan"
                parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "user_ids": user.uid,
                    "v": vkSingleton.shared.version
                ]
                
                successText = "Новости \(user.firstNameGen) \(user.lastNameGen) теперь будут показываться в вашей ленте новостей."
            }
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    if user.isHiddenFromFeed == 0 {
                        controller.userProfile[0].isHiddenFromFeed = 1
                    } else {
                        controller.userProfile[0].isHiddenFromFeed = 0
                    }
                    
                    self.showSuccessMessage(title: "Лента новостей", msg: successText)
                } else {
                    self.showErrorMessage(title: "Лента новостей", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            
            OperationQueue().addOperation(request)
        }
    }
    
    func userInBanList() {
        
        if let controller = self as? ProfileViewController, controller.userProfile.count > 0 {
            
            let user = controller.userProfile[0]
            
            var url = ""
            var parameters: Parameters = [:]
            var successText = ""
            
            if user.blacklistedByMe == 1 {
                url = "/method/account.unbanUser"
                parameters = [
                    "user_id": user.uid,
                    "access_token": vkSingleton.shared.accessToken,
                    "v": vkSingleton.shared.version
                ]
                
                if user.sex == 1 {
                    successText = "\n\(user.firstName) \(user.lastName) успешно удалена из «Черного списка».\n"
                } else {
                    successText = "\n\(user.firstName) \(user.lastName) успешно удален из «Черного списка».\n"
                }
            } else {
                url = "/method/account.banUser"
                parameters = [
                    "user_id": user.uid,
                    "access_token": vkSingleton.shared.accessToken,
                    "v": vkSingleton.shared.version
                ]
                
                if user.sex == 1 {
                    successText = "\n\(user.firstName) \(user.lastName) успешно добавлена в «Черный список».\n"
                } else {
                    successText = "\n\(user.firstName) \(user.lastName) успешно добавлен в «Черный список».\n"
                }
            }
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                let result = json["response"].intValue
                
                if result == 1 {
                    if user.blacklistedByMe == 1 {
                        controller.userProfile[0].blacklistedByMe = 0
                    } else {
                        controller.userProfile[0].blacklistedByMe = 1
                    }
                    
                    OperationQueue.main.addOperation {
                        
                    }
                    self.showSuccessMessage(title: "«Черный список»", msg: successText)
                } else {
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    self.showErrorMessage(title: "«Черный список»", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func groupInFave() {
        
        if let controller = self as? GroupProfileViewController, controller.groupProfile.count > 0 {
            
            let group = controller.groupProfile[0]
            
            var url = ""
            var parameters: Parameters = [:]
            var successText = ""
            
            if group.isFavorite == 1 {
                url = "/method/fave.removeGroup"
                parameters = [
                    "group_id": group.gid,
                    "access_token": vkSingleton.shared.accessToken,
                    "v": vkSingleton.shared.version
                ]
                
                successText = "\nСообщество «\(group.name)» успешно удалено из «Избранное».\n"
                
            } else {
                url = "/method/fave.addGroup"
                parameters = [
                    "group_id": group.gid,
                    "access_token": vkSingleton.shared.accessToken,
                    "v": vkSingleton.shared.version
                ]
                
                successText = "\nСообщество «\(group.name)» успешно добавлено в «Избранное».\n"
            }
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                let result = json["response"].intValue
                
                if result == 1 {
                    if group.isFavorite == 1 {
                        controller.groupProfile[0].isFavorite = 0
                    } else {
                        controller.groupProfile[0].isFavorite = 1
                    }
                    
                    OperationQueue.main.addOperation {
                        
                    }
                    self.showSuccessMessage(title: "Избранные сообщества", msg: successText)
                } else {
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    self.showErrorMessage(title: "Избранные сообщества", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func groupInNewsfeed() {
        if let controller = self as? GroupProfileViewController, controller.groupProfile.count > 0 {
            
            let group = controller.groupProfile[0]
            
            var url = ""
            var parameters: Parameters = [:]
            var successText = ""
            
            if group.isHiddenFromFeed == 0 {
                url = "/method/newsfeed.addBan"
                parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "group_ids": group.gid,
                    "v": vkSingleton.shared.version
                ]
                
                successText = "Новости сообщества «\(group.name)» больше не будут показываться в вашей ленте новостей."
            } else {
                url = "/method/newsfeed.deleteBan"
                parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "group_ids": group.gid,
                    "v": vkSingleton.shared.version
                ]
                
                successText = "Новости сообщества «\(group.name)» теперь будут показываться в вашей ленте новостей."
            }
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    if group.isHiddenFromFeed == 0 {
                        controller.groupProfile[0].isHiddenFromFeed = 1
                    } else {
                        controller.groupProfile[0].isHiddenFromFeed = 0
                    }
                    
                    self.showSuccessMessage(title: "Лента новостей", msg: successText)
                } else {
                    self.showErrorMessage(title: "Лента новостей", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            
            OperationQueue().addOperation(request)
        }
    }
    
    func pinRecord() {
        
        if let controller = self as? RecordController, controller.record.count > 0 {
            
            let record = controller.record[0]
            
            var url = ""
            var parameters: Parameters = [:]
            var successText = ""
            
            if record.isPinned == 1 {
                url = "/method/wall.unpin"
                parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": "\(record.ownerID)",
                    "post_id": "\(record.id)",
                    "v": vkSingleton.shared.version
                ]
                
                successText = "\nЗапись успешно откреплена на стене\n"
                
            } else {
                url = "/method/wall.pin"
                parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": "\(record.ownerID)",
                    "post_id": "\(record.id)",
                    "v": vkSingleton.shared.version
                ]
                
                successText = "\nЗапись успешно закреплена на стене\n"
            }
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    if record.isPinned == 1 {
                        controller.record[0].isPinned = 0
                    } else {
                        controller.record[0].isPinned = 1
                    }
                    
                    OperationQueue.main.addOperation {
                        controller.tableView.reloadData()
                    }
                    self.showSuccessMessage(title: "Запись на стене", msg: successText)
                } else {
                    self.showErrorMessage(title: "Запись на стене", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func fixTopic() {
        
        if let controller = self as? TopicController, controller.topics.count > 0 {
            
            let topic = controller.topics[0]
            
            var url = ""
            
            if topic.isFixed == 0 {
                url = "/method/board.fixTopic"
            } else {
                url = "/method/board.unfixTopic"
            }
            
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "group_id": controller.groupID,
                "topic_id": controller.topicID,
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    if topic.isFixed == 0 {
                        controller.topics[0].isFixed = 1
                    } else {
                        controller.topics[0].isFixed = 0
                    }
                    
                    OperationQueue.main.addOperation {
                        controller.tableView.reloadData()
                        
                        if let delegate = controller.delegate as? TopicsListController {
                            delegate.offset = 0
                            delegate.getTopics()
                        }
                    }
                } else {
                    self.showErrorMessage(title: "Редактирование обсуждения", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func closeTopic() {
        
        if let controller = self as? TopicController, controller.topics.count > 0 {
            
            let topic = controller.topics[0]
            
            var url = ""
            
            if topic.isClosed == 0 {
                url = "/method/board.closeTopic"
            } else {
                url = "/method/board.openTopic"
            }
            
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "group_id": controller.groupID,
                "topic_id": controller.topicID,
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        OperationQueue.main.addOperation {
                            controller.tableView.removeFromSuperview()
                            controller.commentView.removeFromSuperview()
                            
                            controller.createTableView()
                            
                            if topic.isClosed == 0 {
                                controller.topics[0].isClosed = 1
                            
                                controller.tableView.frame = CGRect(x: 0, y: 0, width: controller.width, height: controller.view.bounds.height)
                                controller.view.addSubview(controller.tableView)
                                controller.commentView.removeFromSuperview()
                            } else {
                                controller.topics[0].isClosed = 0
                                controller.view.addSubview(controller.commentView)
                            }
                            
                            controller.tableView.reloadData()
                            
                            if let delegate = controller.delegate as? TopicsListController {
                                delegate.offset = 0
                                delegate.getTopics()
                            }
                        }
                    }
                } else {
                    self.showErrorMessage(title: "Редактирование обсуждения", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func editTopic(newTitle: String) {
        
        if let controller = self as? TopicController {
            let url = "/method/board.editTopic"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "group_id": controller.groupID,
                "topic_id": controller.topicID,
                "title": newTitle,
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    controller.topics[0].title = newTitle
                    OperationQueue.main.addOperation {
                        controller.tableView.reloadData()
                        
                        if let delegate = controller.delegate as? TopicsListController {
                            delegate.offset = 0
                            delegate.getTopics()
                        }
                    }
                } else {
                    self.showErrorMessage(title: "Редактирование обсуждения", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func deleteTopic() {
        
        if let controller = self as? TopicController {
            let url = "/method/board.deleteTopic"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "group_id": controller.groupID,
                "topic_id": controller.topicID,
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        if let delegate = controller.delegate as? TopicsListController {
                            delegate.offset = 0
                            delegate.getTopics()
                        }
                        controller.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.showErrorMessage(title: "Удаление обсуждения", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func addLinkToFave(object: AnyObject) {
        
        var text = ""
        var link = ""
        
        if let controller = self as? RecordController, let record = object as? Record {
            
            text = "Запись на стене \(record.title)"
            link = "https://vk.com/wall\(record.ownerID)_\(record.id)"
            
            if controller.type == "photo" {
                text = "Фотография \(record.title)"
                link = "https://vk.com/photo\(record.ownerID)_\(record.id)"
            }
        } else if let photo = object as? Photo {
            
            text = "Фотография \(photo.title)"
            link = "https://vk.com/photo\(photo.ownerID)_\(photo.id)"
        } else if let video = object as? Video {
            
            text = "Видеозапись «\(video.title)»"
            link = "https://vk.com/video\(video.ownerID)_\(video.id)"
        } else if let controller = self as? TopicController, let topic = object as? Topic {
            
            text = "Обсуждение «\(topic.title)»"
            link = "https://vk.com/topic-\(controller.groupID)_\(controller.topicID)"
        }
        
        let url = "/method/fave.addLink"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "link": link,
            "text": text,
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                self.showSuccessMessage(title: "Избранные ссылки", msg: "\(text) (\(link)) успешно добавлена в «Избранное»")
                
            } else {
                self.showErrorMessage(title: "Избранные ссылки", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func publishPostponedPost() {
        
        if let controller = self as? RecordController, controller.record.count > 0 {
            
            let record = controller.record[0]
            
            let url = "/method/wall.post"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": "\(record.ownerID)",
                "post_id": "\(record.id)",
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        let postID = json["response"]["post_id"].intValue
                        let ownerID = record.ownerID
                        controller.navigationController?.popViewController(animated: true)
                        
                        
                        
                        if let delegate = controller.delegate as? ProfileViewController {
                            delegate.offset = 0
                            delegate.filterRecords = "owner"
                            delegate.refreshExecute()
                            
                            delegate.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
                        } else if let delegate = controller.delegate as? GroupProfileViewController {
                            delegate.offset = 0
                            delegate.filterRecords = "all"
                            delegate.refresh()
                            
                            delegate.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
                        }
                    }
                } else {
                    self.showErrorMessage(title: "Публикация новой записи", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func publishPost() {
        
        if let controller = self as? NewRecordController, let message = controller.textView.text {
            
            let url = "/method/wall.post"
            var parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": controller.ownerID,
                "message": message,
                "attachments": controller.attachPanel.attachments,
                "v": vkSingleton.shared.version
            ]
            
            if controller.postponed {
                if let id = Int(controller.ownerID) {
                    if id > 0 {
                        if controller.onlyFriends {
                            parameters["friends_only"] = "1"
                        }
                    } else if id < 0 {
                        parameters["from_group"] = "1"
                        
                        if controller.addSigner {
                            parameters["signed"] = "1"
                        }
                    }
                }
                
                parameters["publish_date"] = "\(controller.postponedDate)"
            }
            
            if controller.closeComments {
                parameters["close_comments"] = "1"
            } else {
                parameters["close_comments"] = "0"
            }
            
            print(parameters)
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        controller.navigationController?.popViewController(animated: true)
                        
                        let postID = json["response"]["post_id"].intValue
                        
                        if let delegate = controller.delegate as? ProfileViewController {
                            delegate.offset = 0
                            delegate.filterRecords = "owner"
                            delegate.refreshExecute()
                            
                            if let ownerID = Int(controller.ownerID) {
                                delegate.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
                            }
                        } else if let delegate = controller.delegate as? GroupProfileViewController {
                            delegate.offset = 0
                            delegate.filterRecords = "all"
                            delegate.refresh()
                            
                            if let ownerID = Int(controller.ownerID) {
                                delegate.openWallRecord(ownerID: ownerID, postID: postID, accessKey: "", type: "post")
                            }
                        }
                        
                        
                    }
                } else {
                    self.showErrorMessage(title: "Публикация новой записи", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func editPost() {
        
        if let controller = self as? NewRecordController, let record = controller.record, let message = controller.textView.text {
            
            let url = "/method/wall.edit"
            var parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": controller.ownerID,
                "post_id": "\(record.id)",
                "message": message,
                "attachments": controller.attachPanel.attachments,
                "v": vkSingleton.shared.version
            ]
            
            if controller.postponed {
                if let id = Int(controller.ownerID) {
                    if id > 0 {
                        if controller.onlyFriends {
                            parameters["friends_only"] = "1"
                        } else {
                            parameters["friends_only"] = "0"
                        }
                    } else if id < 0 {
                        if controller.addSigner {
                            parameters["signed"] = "1"
                        } else {
                            parameters["signed"] = "0"
                        }
                    }
                }
            
                parameters["publish_date"] = "\(controller.postponedDate)"
            }
            
            if controller.closeComments {
                parameters["close_comments"] = "1"
            } else {
                parameters["close_comments"] = "0"
            }
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        controller.navigationController?.popViewController(animated: true)
                        
                        if let delegate = controller.delegate as? RecordController {
                            delegate.getRecord()
                            
                            if let delegate2 = delegate.delegate as? ProfileViewController {
                                delegate2.offset = 0
                                delegate2.refreshExecute()
                            } else if let delegate2 = delegate.delegate as? GroupProfileViewController {
                                delegate2.offset = 0
                                delegate2.refresh()
                            }
                        }
                    }
                } else {
                    self.showErrorMessage(title: "Редактирование записи", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func deletePost() {
        
        if let controller = self as? RecordController, controller.record.count > 0 {
            let record = controller.record[0]
            
            let url = "/method/wall.delete"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": "\(record.ownerID)",
                "post_id": "\(record.id)",
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        self.navigationController?.popViewController(animated: true)
                        
                        if let delegate = controller.delegate as? ProfileViewController {
                            delegate.offset = 0
                            delegate.filterRecords = "owner"
                            delegate.refreshExecute()
                            
                        } else if let delegate = controller.delegate as? GroupProfileViewController {
                            delegate.offset = 0
                            delegate.filterRecords = "all"
                            delegate.refresh()
                        }
                    }
                } else {
                    self.showErrorMessage(title: "Удаление записи", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func inviteFriendInGroup(friend: Friends) {
        
        if let controller = self as? GroupProfileViewController, controller.groupProfile.count > 0 {
            let group = controller.groupProfile[0]
            
            let url = "/method/groups.invite"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "group_id": "\(group.gid)",
                "user_id": friend.userID,
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    self.showSuccessMessage(title: "Приглашение в сообщество", msg: "Приглашение в сообщество «\(group.name)» успешно выслано \(friend.firstNameDat) \(friend.lastNameDat).")
                } else {
                    self.showErrorMessage(title: "Ошибка приглашения", msg: "#\(error.errorCode): \(error.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
}
