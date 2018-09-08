//
//  vkUserLongPollProtocol.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 07.09.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SWRevealViewController

protocol vkUserLongPollProtocol {
    func getLongPollServer()
    func userLongPoll()
    func handleUpdates()
}

extension MenuViewController: vkUserLongPollProtocol {
    
    func getLongPollServer() {
        
        if vkUserLongPoll.shared.firstLaunch {
            vkUserLongPoll.shared.firstLaunch = false
            
            let url = "/method/messages.getLongPollServer"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "need_pts": "1",
                "lp_version": vkSingleton.shared.lpVersion,
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                vkUserLongPoll.shared.server = json["response"]["server"].stringValue
                vkUserLongPoll.shared.key = json["response"]["key"].stringValue
                vkUserLongPoll.shared.pts = json["response"]["pts"].stringValue
                vkUserLongPoll.shared.ts = json["response"]["ts"].stringValue
                
                vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                
                if vkSingleton.shared.errorCode == 0 {
                    self.userLongPoll()
                }  else {
                    print("Ошибка #\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func userLongPoll() {
        
        autoreleasepool {
            let url = "https://\(vkUserLongPoll.shared.server)"
            let parameters = [
                "act": "a_check",
                "key": vkUserLongPoll.shared.key,
                "ts": vkUserLongPoll.shared.ts,
                "wait": "25",
                "mode": "2",
                "version": vkSingleton.shared.lpVersion
            ]
            
            vkUserLongPoll.shared.request = GetLongPollServerRequest(url: url, parameters: parameters)
            vkUserLongPoll.shared.request.completionBlock = {
                guard let data = vkUserLongPoll.shared.request.data else { return }
                
                guard let json = try? JSON(data: data) else {
                    vkUserLongPoll.shared.request.cancel()
                    vkUserLongPoll.shared.firstLaunch = true
                    self.getLongPollServer()
                    return
                }
                
                let failed = json["failed"].intValue
                vkSingleton.shared.errorCode = json["error"]["error_code"].intValue
                vkSingleton.shared.errorMsg = json["error"]["error_msg"].stringValue
                
                if vkSingleton.shared.errorCode == 0 {
                    if failed == 0 || failed == 1 {
                        vkUserLongPoll.shared.ts = json["ts"].stringValue
                        vkUserLongPoll.shared.updates = json["updates"].compactMap { Updates(json: $0.1) }
                        
                        print(json)
                        
                        self.getUserInfo()
                        self.handleUpdates()
                        
                        self.userLongPoll()
                    } else if failed == 2 && failed == 3 {
                        vkUserLongPoll.shared.request.cancel()
                        vkUserLongPoll.shared.firstLaunch = true
                        self.getLongPollServer()
                    }
                } else {
                    print("#\(vkSingleton.shared.errorCode): \(vkSingleton.shared.errorMsg)")
                    vkUserLongPoll.shared.request.cancel()
                    vkUserLongPoll.shared.firstLaunch = true
                    self.getLongPollServer()
                }
            }
            OperationQueue().addOperation(vkUserLongPoll.shared.request)
        }
    }
    
    func handleUpdates() {
        
        for update in vkUserLongPoll.shared.updates {
            
            if update.elements[0] == 4 {
                
            }
            
            if update.elements[0] == 80 {
                OperationQueue.main.addOperation {
                    self.messagesCell.setBadgeValue(value: update.elements[1])
                }
            }
        }
        
        if let viewControllers = self.navController?.viewControllers {
            for vc in viewControllers {
                if let controller = vc as? DialogController {
                    var typing = false
                    var deleteIDs: [Int] = []
                    var spamIDs: [Int] = []
                    
                    for update in vkUserLongPoll.shared.updates {
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
                                controller.offset = 0
                                controller.loadNewMessages(messageID: update.elements[1])
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
                                    if self.tableView.numberOfSections == 4 {
                                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
                                    }
                                }
                            }
                        } else if update.elements[0] == 7 {
                            if controller.userID == "\(update.elements[1])" {
                                for dialog in controller.dialogs.filter({ $0.readState == 0 && $0.out == 1 }) {
                                    dialog.readState = 1
                                }
                                
                                OperationQueue.main.addOperation {
                                    controller.tableView.reloadData()
                                    if self.tableView.numberOfSections == 4 {
                                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
                                    }
                                }
                            }
                        } else if update.elements[0] == 8 {
                            if controller.userID == "\(abs(update.elements[1]))" {
                                for user in controller.users.filter({ $0.uid == controller.userID }) {
                                    
                                    user.onlineStatus = 1
                                    let platform = update.elements[2] % 256
                                    if platform > 0 && platform != 7 {
                                        user.onlineMobile = 1
                                    }
                                    
                                    OperationQueue.main.addOperation {
                                        if controller.chatID == 0 {
                                            controller.titleView.user = user
                                            controller.titleView.configureUserView()
                                        }
                                    }
                                }
                            }
                        } else if update.elements[0] == 9 {
                            if controller.userID == "\(abs(update.elements[1]))" {
                                for user in controller.users.filter({ $0.uid == controller.userID }) {
                                    user.onlineStatus = 0
                                    user.lastSeen = update.elements[3]
                                    
                                    OperationQueue.main.addOperation {
                                        if controller.chatID == 0 {
                                            controller.titleView.user = user
                                            controller.titleView.configureUserView()
                                        }
                                    }
                                }
                            }
                        } else if update.elements[0] == 61 {
                            if controller.userID == "\(update.elements[1])" {
                                typing = true
                                
                                OperationQueue.main.addOperation {
                                    if controller.chatID == 0 {
                                        controller.titleView.typing = true
                                        controller.titleView.setTyping()
                                    }
                                }
                            }
                        }
                    }
                    
                    if typing == false {
                        OperationQueue.main.addOperation {
                            if controller.chatID == 0 {
                                controller.titleView.timer.invalidate()
                                controller.titleView.typing = false
                                controller.titleView.setTyping()
                            }
                        }
                    }
                    
                    if deleteIDs.count > 0 {
                        var mess = "\(deleteIDs.count.messageAdder()) успешно удалено из диалога"
                        if deleteIDs.count > 1 {
                            mess = "\(deleteIDs.count.messageAdder()) успешно удалены из диалога"
                        }
                        
                        var userID = Int(controller.userID)!
                        if userID > 2000000000 {
                            userID = Int(vkSingleton.shared.userID)!
                        }
                        
                        
                        OperationQueue.main.addOperation {
                            controller.offset = 0
                            controller.getDialog()
                            print(mess)
                        }
                    }
                    
                    if spamIDs.count > 0 {
                        var mess = "\(spamIDs.count.messageAdder()) успешно помечено как спам"
                        if spamIDs.count > 1 {
                            mess = "\(spamIDs.count.messageAdder()) успешно помечены как спам"
                        }
                        
                        var userID = Int(controller.userID)!
                        if userID > 2000000000 {
                            userID = Int(vkSingleton.shared.userID)!
                        }
                        
                        
                        OperationQueue.main.addOperation {
                            print(mess)
                        }
                    }
                }
                
                if let controller = vc as? UsersController {
                    for update in vkUserLongPoll.shared.updates {
                        for user in controller.users.filter({ $0.uid == "\(abs(update.elements[1]))" }) {
                            if update.elements[0] == 8 {
                                    user.onlineStatus = 1
                                    let platform = update.elements[2] % 256
                                    if platform > 0 && platform != 7 {
                                        user.onlineMobile = 1
                                    }
                            } else if update.elements[0] == 9 {
                                user.onlineStatus = 0
                                user.lastSeen = update.elements[3]
                            }
                        }
                    }
                    
                    let onlineCount = controller.users.filter({ $0.onlineStatus == 1 }).count
                    OperationQueue.main.addOperation {
                        controller.tableView.reloadData()
                        controller.segmentedControl.setTitle("Онлайн: \(onlineCount)", forSegmentAt: 1)
                    }
                }
            }
        }
    }
}
