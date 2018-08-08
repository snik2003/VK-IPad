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
}
