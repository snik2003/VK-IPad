//
//  vkGroupLongPollProtocol.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 11.09.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

protocol vkGroupLongPollProtocol {
    
    func getGroupLongPollServer(groupID: Int)
    func groupLongPoll(groupID: Int)
    func handleGroupUpdates(groupID: Int)
    
}

extension MenuViewController: vkGroupLongPollProtocol {
    
    func getGroupLongPollServer(groupID: Int) {
        
        if groupID > 0 && vkGroupLongPoll.shared.firstLaunch[groupID] != false {
            vkGroupLongPoll.shared.firstLaunch[groupID] = false
            
            let url = "/method/messages.getLongPollServer"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "need_pts": "1",
                "lp_version": vkSingleton.shared.lpVersion,
                "group_id": "\(groupID)",
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                vkGroupLongPoll.shared.server[groupID] = json["response"]["server"].stringValue
                vkGroupLongPoll.shared.key[groupID] = json["response"]["key"].stringValue
                vkGroupLongPoll.shared.ts[groupID] = json["response"]["ts"].stringValue
                
                vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                
                if vkSingleton.shared.errorCode == 0 {
                    self.groupLongPoll(groupID: groupID)
                }  else {
                    print("Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func groupLongPoll(groupID: Int) {
        
        autoreleasepool {
            if let server = vkGroupLongPoll.shared.server[groupID], let key = vkGroupLongPoll.shared.key[groupID], let ts = vkGroupLongPoll.shared.ts[groupID] {
                let url = "https://\(server)"
                let parameters = [
                    "act": "a_check",
                    "key": key,
                    "ts": ts,
                    "wait": "25",
                    "mode": "2",
                    "version": vkSingleton.shared.lpVersion
                ]
                
                let request = GetLongPollServerRequest(url: url, parameters: parameters)
                request.completionBlock = {
                    vkGroupLongPoll.shared.request[groupID] = request
                    
                    guard let data = request.data else { return }
                    guard let json = try? JSON(data: data) else {
                        request.cancel()
                        vkGroupLongPoll.shared.firstLaunch[groupID] = true
                        self.getGroupLongPollServer(groupID: groupID)
                        return
                    }
                    
                    let failed = json["failed"].intValue
                    vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                    vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if vkSingleton.shared.errorCode == 0 {
                        if failed == 0 || failed == 1 {
                            vkGroupLongPoll.shared.ts[groupID] = json["ts"].stringValue
                            vkGroupLongPoll.shared.updates[groupID] = json["updates"].compactMap { Updates(json: $0.1) }
                            
                            
                            print("\(groupID): \(json)")
                            
                            self.handleGroupUpdates(groupID: groupID)
                            self.groupLongPoll(groupID: groupID)
                        } else if failed == 2 && failed == 3 {
                            if let request = vkGroupLongPoll.shared.request[groupID] {
                                request.cancel()
                                vkGroupLongPoll.shared.firstLaunch[groupID] = true
                                self.getGroupLongPollServer(groupID: groupID)
                            }
                            
                        }
                    } else {
                        print("\(groupID) - #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                        if let request = vkGroupLongPoll.shared.request[groupID] {
                            request.cancel()
                            vkGroupLongPoll.shared.firstLaunch[groupID] = true
                            self.getGroupLongPollServer(groupID: groupID)
                        }
                    }
                }
                OperationQueue().addOperation(request)
            }
        }
    }
    
    func handleGroupUpdates(groupID: Int) {
        
        if let updates = vkGroupLongPoll.shared.updates[groupID] {
            
            for update in updates {
                if update.elements[0] == 4 {
                    let flags = update.elements[2]
                    var summands: [Int] = []
                    for number in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 65536] {
                        if flags & number != 0 {
                            summands.append(number)
                        }
                    }
                    
                    var text = update.text.prepareTextForPublic()
                    
                    if update.type != "" {
                        if text != "" {
                            text = "\(text)  "
                        }
                        
                        if update.type == "photo" {
                            text = "\(text)[Фотография]"
                        } else if update.type == "video" {
                            text = "\(text)[Видеозапись]"
                        } else if update.type == "sticker" {
                            text = "\(text)[Стикер]"
                        } else if update.type == "wall" {
                            text = "\(text)[Запись на стене]"
                        } else if update.type == "gift" {
                            text = "\(text)[Подарок]"
                        } else if update.type == "doc" {
                            text = "\(text)[Документ]"
                        }
                    }
                    
                    var userID = update.elements[3]
                    if update.fromID != 0 {
                        userID = update.fromID
                    }
                    
                    if !summands.contains(2) && update.action == "" {
                        OperationQueue.main.addOperation {
                            self.mainController?.showMessageNotification(title: "Новое сообщение", text: text, userID: userID, groupID: groupID, startID: update.elements[1])
                        }
                    }
                }
                
                if update.elements[0] == 80 {
                    OperationQueue.main.addOperation {
                        self.messagesCell.setBadgeValue(value: update.elements[1])
                    }
                }
            }
        
            
            if let viewControllers = self.navController?.viewControllers {
                    for vc in viewControllers {
                        
                    if let controller = vc as? DialogController, controller.groupID == groupID {
                        
                        var deleteIDs: [Int] = []
                        var spamIDs: [Int] = []
                        
                        for update in updates {
                            if update.elements[0] == 2 {
                                let flags = update.elements[2]
                                var summands: [Int] = []
                                for number in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 65536, 131072] {
                                    if flags & number != 0 {
                                        summands.append(number)
                                    }
                                }
                                
                                for dialog in controller.dialogs.filter({ $0.id == update.elements[1] }) {
                                    if summands.contains(131072) || summands.contains(128) {
                                        if !deleteIDs.contains(dialog.id) {
                                            deleteIDs.append(dialog.id)
                                        }
                                    }
                                    
                                    if summands.contains(64) {
                                        if !spamIDs.contains(dialog.id) {
                                            spamIDs.append(dialog.id)
                                        }
                                    }
                                }
                            } else if update.elements[0] == 4 {
                                if controller.userID == "\(update.elements[3])" {
                                    
                                    let mess = Dialog(json: JSON.null)
                                    
                                    mess.id = update.elements[1]
                                    mess.userID = update.elements[3]
                                    mess.body = update.text
                                    mess.date = update.elements[4]
                                    mess.emoji = update.emoji
                                    mess.title = update.title
                                    
                                    let flags = update.elements[2]
                                    var summands: [Int] = []
                                    for number in [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 65536] {
                                        if flags & number != 0 {
                                            summands.append(number)
                                        }
                                    }
                                    
                                    if summands.contains(1) {
                                        mess.readState = 0
                                    } else {
                                        mess.readState = 1
                                    }
                                    
                                    if summands.contains(2) {
                                        mess.out = 1
                                        mess.fromID = Int(vkSingleton.shared.userID)!
                                    } else {
                                        mess.out = 0
                                        mess.fromID = mess.userID
                                    }
                                    
                                    if update.type == "" && update.fwdCount == 0 && controller.chatID == 0 {
                                        OperationQueue.main.addOperation {
                                            controller.dialogs.remove(at: 0)
                                            controller.dialogs.append(mess)
                                            controller.totalCount += 1
                                            controller.tableView.reloadData()
                                            controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
                                        }
                                    } else {
                                        OperationQueue.main.addOperation {
                                            controller.offset = 0
                                            controller.startMessageID = update.elements[1]
                                            controller.getDialog()
                                        }
                                    }
                                    
                                    controller.markAsReadMessages()
                                }
                            } else if update.elements[0] == 5 {
                                if controller.userID == "\(update.elements[3])" {
                                    if let id = controller.dialogs.last?.id {
                                        controller.startMessageID = id
                                    }
                                    
                                    OperationQueue.main.addOperation {
                                        controller.offset = 0
                                        controller.getDialog()
                                    }
                                }
                            } else if update.elements[0] == 6 {
                                if controller.userID == "\(update.elements[1])" {
                                    for dialog in controller.dialogs.filter({ $0.readState == 0 && $0.out == 0 }) {
                                        dialog.readState = 1
                                    }
                                    
                                    OperationQueue.main.addOperation {
                                        controller.tableView.reloadData()
                                        controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
                                    }
                                }
                            } else if update.elements[0] == 7 {
                                if controller.userID == "\(update.elements[1])" {
                                    for dialog in controller.dialogs.filter({ $0.readState == 0 && $0.out == 1 }) {
                                        dialog.readState = 1
                                    }
                                    
                                    OperationQueue.main.addOperation {
                                        controller.tableView.reloadData()
                                        controller.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
                                    }
                                }
                            } else if update.elements[0] == 8 {
                                if controller.userID == "\(abs(update.elements[1]))" {
                                    if let user = controller.users.filter({ $0.uid == controller.userID }).first {
                                        
                                        user.onlineStatus = 1
                                        let platform = update.elements[2] % 256
                                        if platform > 0 && platform != 7 {
                                            user.onlineMobile = 1
                                        }
                                        
                                        OperationQueue.main.addOperation {
                                            if controller.chatID == 0 {
                                                controller.titleView.user = user
                                                controller.titleView.configureGroupDialogView()
                                            }
                                        }
                                    }
                                }
                            } else if update.elements[0] == 9 {
                                if controller.userID == "\(abs(update.elements[1]))" {
                                    if let user = controller.users.filter({ $0.uid == controller.userID }).first {
                                        user.onlineStatus = 0
                                        user.lastSeen = update.elements[3]
                                        
                                        OperationQueue.main.addOperation {
                                            if controller.chatID == 0 {
                                                controller.titleView.user = user
                                                controller.titleView.configureGroupDialogView()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        if deleteIDs.count > 0 {
                            var mess = "\(deleteIDs.count.messageAdder()) успешно удалено из диалога"
                            if deleteIDs.count > 1 {
                                mess = "\(deleteIDs.count.messageAdder()) успешно удалены из диалога"
                            }
                            
                            OperationQueue.main.addOperation {
                                controller.offset = 0
                                controller.getDialog()
                                self.mainController?.showMessageNotification(text: mess, userID: -1 * groupID)
                            }
                        }
                        
                        if spamIDs.count > 0 {
                            var mess = "\(spamIDs.count.messageAdder()) успешно помечено как спам"
                            if spamIDs.count > 1 {
                                mess = "\(spamIDs.count.messageAdder()) успешно помечены как спам"
                            }
                            
                            OperationQueue.main.addOperation {
                                self.mainController?.showMessageNotification(text: mess, userID: -1 * groupID)
                            }
                        }
                    }
                }
            }
        }
    }
}
