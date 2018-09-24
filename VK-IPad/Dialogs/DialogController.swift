//
//  DialogController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 24.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import DCCommentView
import SwiftyJSON
import WebKit
import Photos

enum DialogSource {
    case all
    case important
    case preview
}

enum DialogMode {
    case dialog
    case select
    case edit
}

class DialogController: UIViewController, UITableViewDelegate, UITableViewDataSource, DCCommentViewDelegate, WKNavigationDelegate {
    
    var userID = ""
    var chatID = 0
    var groupID = 0
    
    var delegate: UIViewController!
    
    var heights: [IndexPath: CGFloat] = [:]
    var width: CGFloat = 0
    
    var tableView = UITableView()
    var commentView: DCCommentView!
    var titleView = DialogTitleView()
    var attachPanel = AttachPanel()
    var panel = SelectMessagesPanel()
    
    var conversation: [Conversation2] = []
    var dialogs: [Dialog] = []
    var users: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    var startMessageID = -1
    var offset = 0
    var count = 50
    var totalCount = 0
    var mode = DialogMode.dialog
    var source = DialogSource.all
    
    var adminID = ""
    
    var selectedMessages: String {
        let dialogs = self.dialogs.filter({ $0.isSelected })
        
        var selected: [String] = []
        for dialog in dialogs {
            selected.append("\(dialog.id)")
        }
        return selected.map { $0 }.joined(separator: ",")
    }
    
    var detailController: UIViewController? {
        if let split = self.splitViewController {
            let controller = split.viewControllers[0]
            return controller.childViewControllers[0]
        }
        return nil
    }
    
    var pickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = vkSingleton.shared.dialogColor
        
        self.pickerController.delegate = self
        
        self.launchGroupLongPoll()
        self.configureTableView()
        
        self.attachPanel.delegate = self
        self.attachPanel.width = width - 20
        self.attachPanel.reconfigure()
        
        self.tableView.separatorStyle = .none
        
        if self.source == .preview {
            let count = vkSingleton.shared.forwardMessages.count
            self.title = "Вложенные для пересылки сообщения (\(count))"
            
            navigationItem.rightBarButtonItem = nil
            getPreviewMessages()
        } else {
            ViewControllerUtils().showActivityIndicator2(controller: self)
            
            setDialogTitle()
            getDialog()
        
            if userID == vkSingleton.shared.supportGroupID {
                let feedbackText = "Здесь Вы можете оставить отзыв о приложении «ВКлючайся!»:\n\nзадать любой вопрос по функционалу приложения,\nсообщить об обнаруженной ошибке или внести\nпредложение по усовершенствованию приложения.\n\nМы будем рады любому отзыву и обязательно ответим Вам.\n\nЖдём ваших сообщений! 😊"
                
                self.showSuccessMessage(title: "Друзья!", msg: feedbackText)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.showMessageNotification(text: "Привет! Все хорошо!", userID: 451439315)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func launchGroupLongPoll() {
        if groupID > 0 {
            if let detail = self.detailController as? MenuViewController {
                detail.getGroupLongPollServer(groupID: groupID)
            }
        }
    }
    
    func configureTableView() {
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        tableView.backgroundColor = vkSingleton.shared.dialogColor
        
        commentView = DCCommentView(scrollView: self.tableView, frame: self.tableView.bounds)
        commentView.delegate = self
        commentView.tintColor = vkSingleton.shared.mainColor
        
        commentView.sendImage = UIImage(named: "send2")
        commentView.stickerImage = UIImage(named: "sticker")
        commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
            
        commentView.accessoryImage = UIImage(named: "attachment2")?.tint(tintColor: vkSingleton.shared.mainColor)
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
            
        setCommentFromGroupID(id: groupID, controller: self)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(MessageCell.self, forCellReuseIdentifier: "messageCell")
        
        if source == .preview {
            self.view.addSubview(tableView)
        } else {
            self.view.addSubview(commentView)
        }
    }
    
    func didSendComment(_ text: String!) {
        commentView.endEditing(true)
        
        if self.mode == .dialog && source == .all {
            self.sendMessage(message: text)
        }
        
        if self.mode == .edit {
            self.editMessage(message: text)
        }
    }
    
    func didStartTypingComment() {
        self.startTyping()
    }
    
    @objc func tapAccessoryButton(sender: UIButton) {
        commentView.endEditing(true)
        commentView.accessoryButton.buttonTouched()
        
        if self.mode == .dialog || self.attachPanel.editID > 0 {
            let selectView = SelectAttachPanel()
            
            selectView.delegate = self
            selectView.attachPanel = self.attachPanel
            selectView.button = self.commentView.accessoryButton
            
            selectView.ownerID = "\(userID)"
            
            selectView.show()
        }
    }
    
    @objc func tapStickerButton(sender: UIButton) {
        commentView.endEditing(true)
        commentView.stickerButton.buttonTouched()
        
        if self.mode == .dialog {
            let stickerView = StickerView()
            stickerView.width = 320
            stickerView.height = stickerView.width + 70
            
            stickerView.delegate = self
            stickerView.button = self.commentView.stickerButton
            stickerView.numProd = 1
            
            stickerView.show()
        }
    }
    
    func getConversation() {
        
        let url = "/method/messages.getConversationsById"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "peer_ids": "\(userID)",
            "extended": "0",
            "group_id": "\(groupID)",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            self.conversation = json["response"]["items"].compactMap { Conversation2(json: $0.1) }
            
            if self.chatID > 0 {
                let url = "/method/messages.getChat"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "chat_id": "\(self.chatID)",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                getServerDataOperation.completionBlock = {
                    guard let data = getServerDataOperation.data else { return }
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    //print(json)
                    
                    self.adminID = json["response"]["admin_id"].stringValue
                }
                OperationQueue().addOperation(getServerDataOperation)
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func getDialog() {
        
        dialogs.removeAll(keepingCapacity: false)
        users.removeAll(keepingCapacity: false)
        groups.removeAll(keepingCapacity: false)
        heights.removeAll(keepingCapacity: false)
        
        let url = "/method/messages.getHistory"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "\(offset)",
            "count": "\(count)",
            "peer_id": "\(userID)",
            "start_message_id": "-1",
            "group_id": "\(groupID)",
            "v": vkSingleton.shared.version
        ]
        
        if startMessageID > 0 {
            parameters["offset"] = "0"
            parameters["start_message_id"] = "\(startMessageID)"
        }
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            if self.conversation.count == 0 {
                self.getConversation()
            }
            
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let dialogs = json["response"]["items"].compactMap { Dialog(json: $0.1) }
            for dialog in dialogs.reversed() {
                self.dialogs.append(dialog)
            }
            
            self.totalCount = json["response"]["count"].intValue
            let unread = json["response"]["unread"].intValue
            
            var userIDs: [String] = [vkSingleton.shared.userID]
            var groupIDs: [String] = ["\(self.groupID)"]
            
            if let id = Int(self.userID) {
                if id > 0 {
                    userIDs.append(self.userID)
                } else if id < 0 {
                    groupIDs.append("\(abs(id))")
                }
            }
            
            for dialog in dialogs {
                if !userIDs.contains("\(dialog.fromID)") {
                    userIDs.append("\(dialog.fromID)")
                }
                    
                if dialog.actionID > 0 && !userIDs.contains("\(dialog.actionID)") {
                    userIDs.append("\(dialog.actionID)")
                }
                
                for attach in dialog.attachments {
                    if attach.record.count > 0 {
                        let record = attach.record[0]
                        if record.fromID > 0 {
                            userIDs.append("\(record.fromID)")
                        } else if record.fromID < 0 {
                            groupIDs.append("\(abs(record.fromID))")
                        }
                    }
                }
                
                for dialog2 in dialog.fwdMessages {
                    
                    if dialog2.userID > 0 {
                        userIDs.append("\(dialog2.userID)")
                    } else if dialog2.userID < 0 {
                        groupIDs.append("\(abs(dialog2.userID))")
                    }
                    
                    for attach in dialog2.attachments {
                        if attach.record.count > 0 {
                            let record = attach.record[0]
                            if record.fromID > 0 {
                                userIDs.append("\(record.fromID)")
                            } else if record.fromID < 0 {
                                groupIDs.append("\(abs(record.fromID))")
                            }
                        }
                    }
                }
            }
            
            let userList = userIDs.map { $0 }.joined(separator: ", ")
            var code = "var a = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_ids\":\"\(userList)\",\"fields\":\"id,first_name,last_name,last_seen,photo_max_orig,photo_max,deactivated,first_name_abl,first_name_gen,last_name_gen,first_name_acc,last_name_acc,online,can_write_private_message,sex\",\"v\":\"\(vkSingleton.shared.version)\"});\n "
            
            let groupList = groupIDs.map { $0 }.joined(separator: ",")
            code = "\(code) var b = API.groups.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"group_ids\":\"\(groupList)\",\"fields\":\"activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed\",\"v\":\"\(vkSingleton.shared.version)\"});\n "
            
            code = "\(code) return [a,b];"
            
            let url2 = "/method/execute"
            let parameters2 = [
                "access_token": vkSingleton.shared.accessToken,
                "code": code,
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
            getServerDataOperation2.completionBlock = {
                guard let data = getServerDataOperation2.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                //print(json)
                
                self.users = json["response"][0].compactMap { UserProfile(json: $0.1) }
                self.groups = json["response"][1].compactMap { GroupProfile(json: $0.1) }
                
                OperationQueue.main.addOperation {
                    self.offset += self.count
                    self.tableView.reloadData()
                    self.tableView.separatorStyle = .none
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
                    
                    if unread > 0 {
                        self.markAsReadMessages()
                    }
                    ViewControllerUtils().hideActivityIndicator()
                }
            }
            OperationQueue().addOperation(getServerDataOperation2)
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func getImportantMessages() {
        
        dialogs.removeAll(keepingCapacity: false)
        users.removeAll(keepingCapacity: false)
        groups.removeAll(keepingCapacity: false)
        heights.removeAll(keepingCapacity: false)
        ViewControllerUtils().showActivityIndicator2(controller: self)
        
        let url = "/method/messages.getImportantMessages"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "\(offset)",
            "count": "200",
            "peer_id": "\(userID)",
            "fields": "id,first_name,last_name,last_seen,photo_max_orig,photo_max,deactivated,first_name_abl,first_name_gen,last_name_gen,online,can_write_private_message,sex",
            "extended": "1",
            "group_id": "\(groupID)",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            self.totalCount = json["response"]["messages"]["count"].intValue
            
            let dialogs = json["response"]["messages"]["items"].compactMap { Dialog(json: $0.1) }
            for dialog in dialogs.reversed() {
                if "\(dialog.peerID)" == self.userID {
                    self.dialogs.append(dialog)
                } else {
                    self.totalCount -= 1
                }
            }
            
            self.users = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
            self.groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
            
            OperationQueue.main.addOperation {
                self.offset += 200
                self.tableView.reloadData()
                self.tableView.separatorStyle = .none
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func getPreviewMessages() {
        
        dialogs.removeAll(keepingCapacity: false)
        users.removeAll(keepingCapacity: false)
        groups.removeAll(keepingCapacity: false)
        heights.removeAll(keepingCapacity: false)
        ViewControllerUtils().showActivityIndicator2(controller: self)
        
        let forwards = vkSingleton.shared.forwardMessages.sorted().map { $0 }.joined(separator: ",")
        
        let url = "/method/messages.getById"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "message_ids": forwards,
            "extended": "1",
            "fields": "id,first_name,last_name,last_seen,photo_max_orig,photo_max,deactivated,first_name_abl,first_name_gen,last_name_gen,online,can_write_private_message,sex",
            "group_id": "\(groupID)",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            self.totalCount = json["response"]["count"].intValue
            
            self.dialogs = json["response"]["items"].compactMap { Dialog(json: $0.1) }
            self.users = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
            self.groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
            
            self.users.append(vkSingleton.shared.myProfile)
            
            OperationQueue.main.addOperation {
                self.offset += 200
                self.tableView.reloadData()
                self.tableView.separatorStyle = .none
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func loadMoreMessages() {
        
        heights.removeAll(keepingCapacity: false)
        ViewControllerUtils().showActivityIndicator2(controller: self)
        
        let startID = self.dialogs[0].id
        
        let url = "/method/messages.getHistory"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "\(count+1)",
            "peer_id": "\(userID)",
            "start_message_id": "\(startID)",
            "group_id": "\(groupID)",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let dialogs = json["response"]["items"].compactMap { Dialog(json: $0.1) }
            
            var newCount = self.dialogs.count
            for dialog in dialogs {
                if dialog.id < startID {
                    self.dialogs.insert(dialog, at: 0)
                }
            }
            newCount = self.dialogs.count - newCount
            
            self.totalCount = json["response"]["count"].intValue
            
            var userIDs: [String] = []
            var groupIDs: [String] = []
            
            userIDs.append(vkSingleton.shared.userID)
            if let id = Int(self.userID) {
                if id > 0 {
                    userIDs.append(self.userID)
                } else if id < 0 {
                    groupIDs.append("\(abs(id))")
                }
            }
            
            for dialog in dialogs {
                if self.chatID > 0 {
                    if !userIDs.contains("\(dialog.fromID)") {
                        userIDs.append("\(dialog.fromID)")
                    }
                    
                    if dialog.actionID > 0 && !userIDs.contains("\(dialog.actionID)") {
                        userIDs.append("\(dialog.actionID)")
                    }
                }
                
                for attach in dialog.attachments {
                    if attach.record.count > 0 {
                        let record = attach.record[0]
                        if record.fromID > 0 {
                            userIDs.append("\(record.fromID)")
                        } else if record.fromID < 0 {
                            groupIDs.append("\(abs(record.fromID))")
                        }
                    }
                }
                
                for dialog2 in dialog.fwdMessages {
                    if dialog2.userID > 0 {
                        userIDs.append("\(dialog2.userID)")
                    } else if dialog2.userID < 0 {
                        groupIDs.append("\(abs(dialog2.userID))")
                    }
                    
                    for attach in dialog2.attachments {
                        if attach.record.count > 0 {
                            let record = attach.record[0]
                            if record.fromID > 0 {
                                userIDs.append("\(record.fromID)")
                            } else if record.fromID < 0 {
                                groupIDs.append("\(abs(record.fromID))")
                            }
                        }
                    }
                }
            }
            
            let userList = userIDs.map { $0 }.joined(separator: ", ")
            var code = "var a = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_ids\":\"\(userList)\",\"fields\":\"id,first_name,last_name,last_seen,photo_max_orig,photo_max,deactivated,first_name_abl,first_name_gen,last_name_gen,first_name_acc,last_name_acc,online,can_write_private_message,sex\",\"v\":\"\(vkSingleton.shared.version)\"});\n "
            
            let groupList = groupIDs.map { $0 }.joined(separator: ",")
            code = "\(code) var b = API.groups.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"group_ids\":\"\(groupList)\",\"fields\":\"activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed\",\"v\":\"\(vkSingleton.shared.version)\"});\n "
            
            code = "\(code) return [a,b];"
            
            let url2 = "/method/execute"
            let parameters2 = [
                "access_token": vkSingleton.shared.accessToken,
                "code": code,
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
            getServerDataOperation2.completionBlock = {
                guard let data = getServerDataOperation2.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                //print(json)
                
                let users = json["response"][0].compactMap { UserProfile(json: $0.1) }
                for user in users {
                    self.users.append(user)
                }
                
                let groups = json["response"][1].compactMap { GroupProfile(json: $0.1) }
                for group in groups {
                    self.groups.append(group)
                }
                
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                    self.tableView.separatorStyle = .none
                    self.tableView.scrollToRow(at: IndexPath(row: newCount+1, section: 2), at: .bottom, animated: false)
                    ViewControllerUtils().hideActivityIndicator()
                }
            }
            OperationQueue().addOperation(getServerDataOperation2)
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func loadMoreImportantMessages() {
        
        heights.removeAll(keepingCapacity: false)
        ViewControllerUtils().showActivityIndicator2(controller: self)
        
        let url = "/method/messages.getImportantMessages"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "\(offset)",
            "count": "200",
            "peer_id": "\(userID)",
            "fields": "id,first_name,last_name,last_seen,photo_max_orig,photo_max,deactivated,first_name_abl,first_name_gen,last_name_gen,online,can_write_private_message,sex",
            "extended": "1",
            "group_id": "\(groupID)",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            self.totalCount = json["response"]["messages"]["count"].intValue
            
            var newCount = self.dialogs.count
            let dialogs = json["response"]["messages"]["items"].compactMap { Dialog(json: $0.1) }
            for dialog in dialogs {
                if "\(dialog.peerID)" == self.userID && !self.dialogs.contains(dialog) {
                    self.dialogs.insert(dialog, at: 0)
                } else {
                    self.totalCount -= 1
                }
            }
            newCount = self.dialogs.count - newCount
            
            let users = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
            for user in users {
                self.users.append(user)
            }
            
            let groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
            for group in groups {
                self.groups.append(group)
            }
            
            OperationQueue.main.addOperation {
                self.offset += 200
                self.tableView.reloadData()
                self.tableView.separatorStyle = .none
                self.tableView.scrollToRow(at: IndexPath(row: newCount+1, section: 2), at: .bottom, animated: false)
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func loadNewMessages(messageID: Int) {
        
        heights.removeAll(keepingCapacity: false)
        
        let url = "/method/messages.getHistory"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "1",
            "peer_id": "\(userID)",
            "start_message_id": "\(messageID)",
            "group_id": "\(groupID)",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let dialogs = json["response"]["items"].compactMap { Dialog(json: $0.1) }
            
            var userIDs: [String] = []
            var groupIDs: [String] = []
            
            for dialog in dialogs {
                if dialog.id == messageID {
                    self.dialogs.append(dialog)
                    self.totalCount += 1
                }
                
                if self.chatID > 0 {
                    if !userIDs.contains("\(dialog.fromID)") {
                        userIDs.append("\(dialog.fromID)")
                    }
                    
                    if dialog.actionID > 0 && !userIDs.contains("\(dialog.actionID)") {
                        userIDs.append("\(dialog.actionID)")
                    }
                }
                
                for attach in dialog.attachments {
                    if attach.record.count > 0 {
                        let record = attach.record[0]
                        if record.fromID > 0 {
                            userIDs.append("\(record.fromID)")
                        } else if record.fromID < 0 {
                            groupIDs.append("\(abs(record.fromID))")
                        }
                    }
                }
                
                for dialog2 in dialog.fwdMessages {
                    if dialog2.userID > 0 {
                        userIDs.append("\(dialog2.userID)")
                    } else if dialog2.userID < 0 {
                        groupIDs.append("\(abs(dialog2.userID))")
                    }
                    
                    for attach in dialog2.attachments {
                        if attach.record.count > 0 {
                            let record = attach.record[0]
                            if record.fromID > 0 {
                                userIDs.append("\(record.fromID)")
                            } else if record.fromID < 0 {
                                groupIDs.append("\(abs(record.fromID))")
                            }
                        }
                    }
                }
            }
            
            let userList = userIDs.map { $0 }.joined(separator: ", ")
            var code = "var a = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_ids\":\"\(userList)\",\"fields\":\"id,first_name,last_name,last_seen,photo_max_orig,photo_max,deactivated,first_name_abl,first_name_gen,last_name_gen,first_name_acc,last_name_acc,online,can_write_private_message,sex\",\"v\":\"\(vkSingleton.shared.version)\"});\n "
            
            let groupList = groupIDs.map { $0 }.joined(separator: ",")
            code = "\(code) var b = API.groups.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"group_ids\":\"\(groupList)\",\"fields\":\"activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed\",\"v\":\"\(vkSingleton.shared.version)\"});\n "
            
            code = "\(code) return [a,b];"
            
            let url2 = "/method/execute"
            let parameters2 = [
                "access_token": vkSingleton.shared.accessToken,
                "code": code,
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
            getServerDataOperation2.completionBlock = {
                guard let data = getServerDataOperation2.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                //print(json)
                
                let users = json["response"][0].compactMap { UserProfile(json: $0.1) }
                for user in users {
                    self.users.append(user)
                }
                
                let groups = json["response"][1].compactMap { GroupProfile(json: $0.1) }
                for group in groups {
                    self.groups.append(group)
                }
                
                OperationQueue.main.addOperation {
                    self.tableView.reloadData()
                    self.tableView.separatorStyle = .none
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
                    self.markAsReadMessages()
                }
            }
            OperationQueue().addOperation(getServerDataOperation2)
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return dialogs.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return attachPanel.frame.height
        case 1:
            if dialogs.count < totalCount {
                return 50
            }
            return 5
        case 2:
            if let height = heights[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell") as! MessageCell
            
                cell.delegate = self
                cell.dialog = self.dialogs[indexPath.row]
                let height = cell.configureCell(calcHeight: true)
                heights[indexPath] = height
                
                return height
            }
        case 3:
            return 70
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
            
            cell.delegate = self
            cell.configureLoadMoreCell()
            
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
            
            cell.delegate = self
            cell.dialog = self.dialogs[indexPath.row]
            cell.indexPath = indexPath
            let _ = cell.configureCell(calcHeight: false)
            
            if groupID == 0 {
                let doubleTap = UITapGestureRecognizer(target: self, action: #selector(goSelectMode(sender:)))
                doubleTap.numberOfTapsRequired = 2
                cell.addGestureRecognizer(doubleTap)
            }
            
            let longTap = UILongPressGestureRecognizer(target: self, action: #selector(goEditMode(sender:)))
            longTap.minimumPressDuration = 0.6
            cell.addGestureRecognizer(longTap)
            
            cell.selectionStyle = .none
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.backgroundColor = vkSingleton.shared.dialogColor
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func setDialogTitle() {
        OperationQueue.main.addOperation {
            self.titleView.delegate = self
            self.titleView.configure()
        }
    }
    
    func sendMessage(message: String, stickerID: Int = 0) {
        
        let url = "/method/messages.send"
        var parameters: [String: Any] = [
            "access_token": vkSingleton.shared.accessToken,
            "peer_id": userID,
            "message": message,
            "attachment": attachPanel.attachments,
            "group_id": "\(groupID)",
            "v": vkSingleton.shared.version
        ]
        
        if attachPanel.forwards != "" {
            parameters["forward_messages"] = attachPanel.forwards
        }
        
        if stickerID != 0 {
            parameters["sticker_id"] = stickerID
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                //let messID = json["response"].intValue
                
                OperationQueue.main.addOperation {
                    vkSingleton.shared.forwardMessages.removeAll(keepingCapacity: false)
                    self.clearSelectedMessages()
                    
                    self.commentView.textView.text = ""
                    self.attachPanel.attachArray.removeAll(keepingCapacity: false)
                    self.attachPanel.forwards = ""
                    self.attachPanel.replyID = 0
                }
            } else {
                if stickerID > 0 {
                    self.showErrorMessage(title: "Ошибка при отправке стикера", msg: "Данный набор стикеров необходимо активировать в полной версии сайта (https://vk.com/stickers?tab=free).")
                } else {
                    self.showErrorMessage(title: "Отправка сообщения", msg: "#\(error.errorCode): \(error.errorMsg)")
                }
            }
            self.setOfflineStatus(dependence: request)
        }
        OperationQueue().addOperation(request)
    }
    
    func editMessage(message: String) {
        
        let url = "/method/messages.edit"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "peer_id": userID,
            "message_id": "\(attachPanel.editID)",
            "message": message,
            "attachment": attachPanel.attachments,
            "keep_forward_messages": "1",
            "keep_snippets": "1",
            "group_id": "\(groupID)",
            "v": vkSingleton.shared.version
        ]
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        request.completionBlock = {
            guard let data = request.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                OperationQueue.main.addOperation {
                    self.offset = 0
                    
                    self.mode = .dialog
                    self.panel.reconfigure()
                    
                    vkSingleton.shared.forwardMessages.removeAll(keepingCapacity: false)
                    self.clearSelectedMessages()
                    
                    self.commentView.textView.text = ""
                    self.attachPanel.attachArray.removeAll(keepingCapacity: false)
                    self.attachPanel.forwards = ""
                    self.attachPanel.editID = 0
                    self.attachPanel.reconfigure()
                    
                    self.dialogs.removeAll(keepingCapacity: false)
                    self.tableView.reloadData()
                    
                    self.getDialog()
                }
            } else {
                self.showErrorMessage(title: "Редактирования сообщения", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
            self.setOfflineStatus(dependence: request)
        }
        OperationQueue().addOperation(request)
    }
    
    func setImportantSelectedMessages() {
        for dialog in self.dialogs {
            if dialog.isSelected {
                dialog.important = 1
            }
        }
    }
    
    func unsetImportantSelectedMessages() {
        for dialog in self.dialogs {
            if dialog.isSelected {
                dialog.important = 0
            }
        }
    }
    
    func clearSelectedMessages() {
        for dialog in self.dialogs {
            dialog.isSelected = false
        }
    }
    
    @objc func goSelectMode(sender: UITapGestureRecognizer) {
        if mode == .dialog && source != .preview {
            if sender.state == .ended {
                let buttonPosition: CGPoint = sender.location(in: self.tableView)
                
                if let indexPath = self.tableView.indexPathForRow(at: buttonPosition), indexPath.section == 2 {
                    if mode == .dialog {
                        mode = .select
                        
                        panel.delegate = self
                        if indexPath.row < tableView.numberOfRows(inSection: 2) - 1 {
                            panel.indexPath = IndexPath(row: indexPath.row + 1, section: 2)
                        } else {
                            panel.indexPath = IndexPath(row: 0, section: 3)
                        }
                        panel.reconfigure()
                    }
                }
            }
        }
    }
    
    @objc func goEditMode(sender: UILongPressGestureRecognizer) {
        if mode == .dialog && source != .preview {
            if sender.state == .ended {
                let buttonPosition: CGPoint = sender.location(in: self.tableView)
                
                if let indexPath = self.tableView.indexPathForRow(at: buttonPosition), indexPath.section == 2 {
                    dialogs[indexPath.row].isSelected = true
                    mode = .edit
                    
                    panel.delegate = self
                    panel.dialog = dialogs[indexPath.row]
                    if indexPath.row < tableView.numberOfRows(inSection: 2) - 1 {
                        panel.indexPath = IndexPath(row: indexPath.row + 1, section: 2)
                    } else {
                        panel.indexPath = IndexPath(row: 0, section: 3)
                    }
                    panel.reconfigure()
                }
            }
        }
    }
    
    func tapDialogTitleView() {
        
        if let userID = Int(self.userID) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            
            if userID > 0 {
                let action1 = UIAlertAction(title: "Перейти в профиль собеседника", style: .default) { action in
                    
                    self.openProfileController(id: userID, name: "")
                }
                alertController.addAction(action1)
            } else if userID < 0 {
                let action1 = UIAlertAction(title: "Перейти на страницу сообщества", style: .default) { action in
                    
                    self.openProfileController(id: userID, name: "")
                }
                alertController.addAction(action1)
            }
        
        
            if mode == .dialog && userID > 0 {
                if self.source == .all {
                    let action3 = UIAlertAction(title: "Показать важные сообщения", style: .default) { action in
                        
                        self.title = "Важные сообщения"
                        self.source = .important
                        self.offset = 0
                        
                        self.getImportantMessages()
                    }
                    alertController.addAction(action3)
                } else {
                    let action3 = UIAlertAction(title: "Показать вcе сообщения", style: .default) { action in
                        
                        self.title = ""
                        self.source = .all
                        self.offset = 0
                        
                        ViewControllerUtils().showActivityIndicator2(controller: self)
                        self.getDialog()
                    }
                    alertController.addAction(action3)
                }
            }
        
        
            /*if dialogs.count < totalCount {
                if self.source == .all {
                    let action4 = UIAlertAction(title: "Дозагрузить сообщения в беседу", style: .destructive) { action in
                        
                        self.loadMoreMessages()
                    }
                    alertController.addAction(action4)
                }
                
                if self.source == .important {
                    let action4 = UIAlertAction(title: "Дозагрузить сообщения в беседу", style: .destructive) { action in
                        
                        self.loadMoreImportantMessages()
                    }
                    alertController.addAction(action4)
                }
            }*/
            
            
            if let popoverController = alertController.popoverPresentationController {
                let bounds = self.titleView.bounds
                popoverController.sourceView = self.titleView
                popoverController.sourceRect = CGRect(x: bounds.maxX - 18, y: bounds.maxY + 5, width: 0, height: 0)
                popoverController.permittedArrowDirections = [.up]
            }
        
            self.present(alertController, animated: true)
        }
    }
    
    func tapChatTitleView() {
        
        if chatID > 0 && conversation.count > 0 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            
            let action1 = UIAlertAction(title: "Добавить в «Избранное»", style: .default) { action in
                
                self.addLinkToFave(object: self.conversation[0])
            }
            alertController.addAction(action1)
            
            
            let action2 = UIAlertAction(title: "Участники групповой беседы", style: .default) { action in
                
                let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
                
                usersController.userID = vkSingleton.shared.userID
                usersController.type = "chat_users"
                usersController.source = ""
                usersController.chat = self.conversation[0]
                usersController.title = "Участники беседы «\(self.conversation[0].chatSettings.title)»"
                
                usersController.delegate = self
                
                let detailVC = self.splitViewController!.viewControllers[self.splitViewController!.viewControllers.endIndex - 1]
                detailVC.childViewControllers[0].navigationController?.pushViewController(usersController, animated: true)
            }
            alertController.addAction(action2)
            
            
            let action9 = UIAlertAction(title: "Добавить друзей в беседу", style: .default){ action in
                
                let usersController = self.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
                
                usersController.userID = vkSingleton.shared.userID
                usersController.type = "friends"
                usersController.source = "add_to_chat"
                usersController.title = "Пригласить друзей в беседу «\(self.conversation[0].chatSettings.title)»"
                
                usersController.delegate = self
                
                if let split = self.splitViewController {
                    let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                    detail.childViewControllers[0].navigationController?.pushViewController(usersController, animated: true)
                }
            }
            alertController.addAction(action9)
            
            
            if mode == .dialog {
                if self.source == .all {
                    let action3 = UIAlertAction(title: "Показать важные сообщения", style: .default) { action in
                        
                        self.title = "Важные сообщения"
                        self.source = .important
                        self.offset = 0
                        
                        self.getImportantMessages()
                    }
                    alertController.addAction(action3)
                } else {
                    let action3 = UIAlertAction(title: "Показать вcе сообщения", style: .default) { action in
                        
                        self.title = ""
                        self.source = .all
                        self.offset = 0
                        
                        ViewControllerUtils().showActivityIndicator2(controller: self)
                        self.getDialog()
                    }
                    alertController.addAction(action3)
                }
            }
            
            
            if adminID == vkSingleton.shared.userID {
                let action7 = UIAlertAction(title: "Изменить название беседы", style: .default){ action in
                    
                    self.editChatTitle()
                }
                alertController.addAction(action7)
                
                
                let action8 = UIAlertAction(title: "Ссылка-приглашение в беседу", style: .default){ action in
                    
                    let alertController2 = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alertController2.addAction(cancelAction)
                    
                    
                    let action1 = UIAlertAction(title: "Получить предыдущую ссылку", style: .default) { action in
                        
                        self.getLinkToChat(reset: "0")
                    }
                    alertController2.addAction(action1)
                    
                    
                    let action2 = UIAlertAction(title: "Сгенерировать новую ссылку", style: .destructive) { action in
                        
                        self.getLinkToChat(reset: "1")
                    }
                    alertController2.addAction(action2)
                    
                    
                    if let popoverController = alertController2.popoverPresentationController {
                        let bounds = self.titleView.bounds
                        popoverController.sourceView = self.titleView
                        popoverController.sourceRect = CGRect(x: bounds.maxX - 18, y: bounds.maxY + 5, width: 0, height: 0)
                        popoverController.permittedArrowDirections = [.up]
                    }
                    
                    self.present(alertController2, animated: true)
                }
                alertController.addAction(action8)
                
                
                if conversation[0].chatSettings.photo100 == "" {
                    let action5 = UIAlertAction(title: "Установить фотографию беседы", style: .default){ action in
                        
                        let alertController2 = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                        
                        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                        alertController2.addAction(cancelAction)
                        
                        
                        let action1 = UIAlertAction(title: "Загрузить с устройства", style: .default) { action in
                            
                            self.pickerController.allowsEditing = false
                            self.pickerController.sourceType = .photoLibrary
                            self.pickerController.mediaTypes =  UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.myOrientation = .all
                            
                            let status = PHPhotoLibrary.authorizationStatus()
                            switch status {
                            case .authorized:
                                self.present(self.pickerController, animated: true)
                            case .denied, .restricted:
                                self.showErrorMessage(title: "Загрузить с устройства", msg: "Доступ к галерее устройства запрещен.\nВы можете поменять это в разделе «Настройки»\nвашего устройства.")
                            case .notDetermined:
                                PHPhotoLibrary.requestAuthorization() { status in
                                    if status == .authorized {
                                        self.present(self.pickerController, animated: true)
                                    }
                                }
                            }
                        }
                        alertController2.addAction(action1)
                        
                        
                        let action2 = UIAlertAction(title: "Сфотографировать", style: .default) { action in
                            
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
                                switch status {
                                case .authorized:
                                    self.pickerController.sourceType = .camera
                                    self.pickerController.cameraCaptureMode = .photo
                                    self.pickerController.modalPresentationStyle = .currentContext
                                    
                                    self.present(self.pickerController, animated: true)
                                case .denied, .restricted:
                                    self.showErrorMessage(title: "Сфотографировать", msg: "Доступ к камере устройства запрещен.\nВы можете поменять это в разделе «Настройки»\nвашего устройства.")
                                case .notDetermined:
                                    AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                                        if granted {
                                            self.pickerController.sourceType = .camera
                                            self.pickerController.cameraCaptureMode = .photo
                                            self.pickerController.modalPresentationStyle = .currentContext
                                            
                                            self.present(self.pickerController, animated: true)
                                        }
                                    }
                                }
                            } else {
                                self.showErrorMessage(title: "Сфотографировать", msg: "Камера не активна либо отсутствует на устройстве.")
                            }
                        }
                        alertController2.addAction(action2)
                        
                        
                        if let popoverController = alertController2.popoverPresentationController {
                            let bounds = self.titleView.bounds
                            popoverController.sourceView = self.titleView
                            popoverController.sourceRect = CGRect(x: bounds.maxX - 18, y: bounds.maxY + 5, width: 0, height: 0)
                            popoverController.permittedArrowDirections = [.up]
                        }
                        
                        self.present(alertController2, animated: true)
                    }
                    alertController.addAction(action5)
                } else {
                    let action6 = UIAlertAction(title: "Удалить фотографию беседы", style: .destructive){ action in
                        
                        self.deleteChatPhoto()
                    }
                    alertController.addAction(action6)
                }
            } else {
                let action10 = UIAlertAction(title: "Покинуть групповую беседу", style: .destructive) { action in
                    
                    self.removeFromChat()
                }
                alertController.addAction(action10)
            }
            
            
            /*if dialogs.count < totalCount {
                if self.source == .all {
                    let action4 = UIAlertAction(title: "Дозагрузить сообщения в беседу", style: .destructive) { action in
                        
                        self.loadMoreMessages()
                    }
                    alertController.addAction(action4)
                }
                
                if self.source == .important {
                    let action4 = UIAlertAction(title: "Дозагрузить сообщения в беседу", style: .destructive) { action in
                        
                        self.loadMoreImportantMessages()
                    }
                    alertController.addAction(action4)
                }
            }*/
            
            
            if let popoverController = alertController.popoverPresentationController {
                let bounds = self.titleView.bounds
                popoverController.sourceView = self.titleView
                popoverController.sourceRect = CGRect(x: bounds.maxX - 18, y: bounds.maxY + 5, width: 0, height: 0)
                popoverController.permittedArrowDirections = [.up]
            }
            
            self.present(alertController, animated: true)
        }
    }
    
    func tapGroupDialogTitleView() {
        
        if let userID = Int(self.userID) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            
            
            let action1 = UIAlertAction(title: "Перейти в профиль собеседника", style: .default) { action in
                
                self.openProfileController(id: userID, name: "")
            }
            alertController.addAction(action1)
        
            
            let action2 = UIAlertAction(title: "Перейти на страницу сообщества", style: .default) { action in
                    
                self.openProfileController(id: -1 * self.groupID, name: "")
            }
            alertController.addAction(action2)
            
            
            if conversation.count > 0 {
                if conversation[0].important == 0 {
                    let action3 = UIAlertAction(title: "Пометить беседу как важную", style: .default) { action in
                        
                        self.setImportantConversation()
                    }
                    alertController.addAction(action3)
                    
                } else {
                    let action3 = UIAlertAction(title: "Отменить беседу как важную", style: .destructive) { action in
                        
                        self.setImportantConversation()
                    }
                    alertController.addAction(action3)
                }
            }
            
            /*if dialogs.count < totalCount {
                if self.source == .all {
                    let action4 = UIAlertAction(title: "Дозагрузить сообщения в беседу", style: .destructive) { action in
                        
                        self.loadMoreMessages()
                    }
                    alertController.addAction(action4)
                }
                
                if self.source == .important {
                    let action4 = UIAlertAction(title: "Дозагрузить сообщения в беседу", style: .destructive) { action in
                        
                        self.loadMoreImportantMessages()
                    }
                    alertController.addAction(action4)
                }
            }*/
            
            
            if let popoverController = alertController.popoverPresentationController {
                let bounds = self.titleView.bounds
                popoverController.sourceView = self.titleView
                popoverController.sourceRect = CGRect(x: bounds.maxX - 18, y: bounds.maxY + 5, width: 0, height: 0)
                popoverController.permittedArrowDirections = [.up]
            }
            
            self.present(alertController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if source == .preview {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if source == .preview && indexPath.section == 2 {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Удалить\nиз вложения") { (rowAction, indexPath) in
                
                let dialog = self.dialogs[indexPath.row]
                
                self.dialogs.remove(object: dialog)
                self.totalCount -= 1
                vkSingleton.shared.forwardMessages.remove(object: "\(dialog.id)")
                
                self.title = "Вложенные для пересылки сообщения"
                let count = vkSingleton.shared.forwardMessages.count
                if count > 0 {
                    self.title = "Вложенные для пересылки сообщения (\(count))"
                }
                
                self.tableView.reloadData()
                if let controller = self.delegate as? DialogController {
                    controller.attachPanel.forwards = ""
                    controller.attachPanel.reconfigure()
                }
            }
            deleteAction.backgroundColor = .red
            
            return [deleteAction]
        }
        
        return []
    }
    
    func editChatTitle() {
        let alert = UIAlertController(title: "Изменить название беседы", message: "Введите новое название групповой беседы:", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = self.conversation[0].chatSettings.title
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(cancelAction)
        
        let action = UIAlertAction(title: "Готово", style: .default) { [weak alert] (_) in
            if let text = alert?.textFields?.first?.text {
                if text != "" {
                    self.editChat(newTitle: text)
                } else {
                    self.showErrorMessage(title: "Ошибка редактирования беседы", msg: "Необходимо ввести новое название беседы.")
                }
            } else {
                self.showErrorMessage(title: "Ошибка редактирования беседы", msg: "Необходимо ввести новое название беседы.")
            }
        }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension DialogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myOrientation = .landscape
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.loadChatPhotoToServer(image: chosenImage)
        }
    
        picker.dismiss(animated:true, completion: nil)
    }
}
