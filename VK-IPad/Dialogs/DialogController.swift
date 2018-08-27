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
import RxSwift
import RxCocoa

enum DialogMode {
    case dialog
}

class DialogController: UIViewController, UITableViewDelegate, UITableViewDataSource, DCCommentViewDelegate {
    
    var userID = ""
    
    var delegate: UIViewController!
    
    var heights: [IndexPath: CGFloat] = [:]
    var width: CGFloat = 0
    
    var tableView = UITableView()
    var commentView: DCCommentView!
    var attachPanel = AttachPanel()
    
    var dialogs: [Dialog] = []
    var users: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    var startMessageID = -1
    var offset = 0
    var count = 50
    var totalCount = 0
    var mode = DialogMode.dialog
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = vkSingleton.shared.dialogColor
        
        self.attachPanel.delegate = self
        self.configureTableView()
        
        self.tableView.separatorStyle = .none
        
        setDialogTitle()
        getDialog()
        
        if userID == vkSingleton.shared.supportGroupID {
            let feedbackText = "Здесь Вы можете оставить отзыв о приложении «ВКлючайся!»:\n\nзадать любой вопрос по функционалу приложения,\nсообщить об обнаруженной ошибке или внести\nпредложение по усовершенствованию приложения.\n\nМы будем рады любому отзыву и обязательно ответим Вам.\n\nЖдём ваших отзывов! 😊"
            
            self.showSuccessMessage(title: "Друзья!", msg: feedbackText)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureTableView() {
        tableView.frame = CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height)
        tableView.backgroundColor = vkSingleton.shared.dialogColor
        
        commentView = DCCommentView(scrollView: self.tableView, frame: self.tableView.bounds)
        commentView.delegate = self
        commentView.tintColor = vkSingleton.shared.mainColor
        
        commentView.sendImage = UIImage(named: "send2")
        commentView.stickerImage = UIImage(named: "sticker")
        commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
            
        commentView.accessoryImage = UIImage(named: "attachment2")?.tint(tintColor: vkSingleton.shared.mainColor)
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
            
        setCommentFromGroupID(id: 0, controller: self)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(MessageCell.self, forCellReuseIdentifier: "messageCell")
        self.view.addSubview(commentView)
    }
    
    func didSendComment(_ text: String!) {
        
    }
    
    @objc func tapAccessoryButton(sender: UIButton) {
        commentView.endEditing(true)
        commentView.accessoryButton.buttonTouched()
        
        let selectView = SelectAttachPanel()
        
        selectView.delegate = self
        selectView.attachPanel = self.attachPanel
        selectView.button = self.commentView.accessoryButton
        
        selectView.ownerID = "\(userID)"
        
        selectView.show()
    }
    
    @objc func tapStickerButton(sender: UIButton) {
        commentView.endEditing(true)
        commentView.stickerButton.buttonTouched()
        
        let stickerView = StickerView()
        stickerView.width = 320
        stickerView.height = stickerView.width + 70
        
        stickerView.delegate = self
        stickerView.button = self.commentView.stickerButton
        stickerView.numProd = 1
        
        stickerView.show()
    }
    
    func getDialog() {
        
        heights.removeAll(keepingCapacity: false)
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        let url = "/method/messages.getHistory"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "\(offset)",
            "count": "\(count)",
            "peer_id": "\(userID)",
            "start_message_id": "-1",
            "v": vkSingleton.shared.version
        ]
        
        if startMessageID > 0 {
            parameters["offset"] = "0"
            parameters["start_message_id"] = "\(startMessageID)"
        }
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let dialogs = json["response"]["items"].compactMap { Dialog(json: $0.1) }
            for dialog in dialogs.reversed() {
                self.dialogs.append(dialog)
            }
            
            self.totalCount = json["response"]["count"].intValue
            let unread = json["response"]["unread"].intValue
            
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
            
            let userList = userIDs.map { $0 }.joined(separator: ", ")
            var code = "var a = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_ids\":\"\(userList)\",\"fields\":\"id,first_name,last_name,last_seen,photo_max_orig,photo_max,deactivated,first_name_abl,first_name_gen,online,can_write_private_message,sex\",\"v\":\"\(vkSingleton.shared.version)\"});\n "
            
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
                    
                    //print("count = \(self.dialogs.count), total = \(self.totalCount)")
                    if unread > 0 {
                        // помечаем непрочитанные сообщения как прочитанные
                    }
                    ViewControllerUtils().hideActivityIndicator()
                }
            }
            OperationQueue().addOperation(getServerDataOperation2)
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func loadMoreMessages() {
        
        heights.removeAll(keepingCapacity: false)
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        let startID = self.dialogs[0].id
        
        let url = "/method/messages.getHistory"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "\(count+1)",
            "peer_id": "\(userID)",
            "start_message_id": "\(startID)",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
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
            
            let userList = userIDs.map { $0 }.joined(separator: ", ")
            var code = "var a = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_ids\":\"\(userList)\",\"fields\":\"id,first_name,last_name,last_seen,photo_max_orig,photo_max,deactivated,first_name_abl,first_name_gen,online,can_write_private_message,sex\",\"v\":\"\(vkSingleton.shared.version)\"});\n "
            
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
            return 60
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
            
            cell.selectionStyle = .none
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            cell.backgroundColor = vkSingleton.shared.dialogColor
            
            return cell
        }
    }
    
    func setDialogTitle() {
        OperationQueue.main.addOperation {
            let titleView = DialogTitleView()
            titleView.delegate = self
            titleView.configure()
        }
    }
}
