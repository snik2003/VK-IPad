//
//  TopicController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 31.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView
import DCCommentView
import Popover

class TopicController: UIViewController, UITableViewDelegate, UITableViewDataSource, DCCommentViewDelegate {
    
    var groupID = ""
    var topicID = ""
    
    var group: [GroupProfile] = []
    
    var offset = 0
    var count = 30
    
    var topics: [Topic] = []
    var topicUsers: [UserProfile] = []
    
    var comments: [Comment] = []
    var users: [UserProfile] = []
    var groups: [GroupProfile] = []
    var total = 0
    
    var width: CGFloat = 0
    var heights: [IndexPath: CGFloat] = [:]
    
    var tableView: UITableView!
    var commentView: DCCommentView!
    //var optButton: UIBarButtonItem!
    
    var delegate: UIViewController!

    var attachPanel = AttachPanel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attachPanel.delegate = self
        
        createTableView()
        getTopicComments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func createTableView() {
        tableView = UITableView()
        
        tableView.frame = CGRect(x: 0, y: 0, width: self.width, height: self.view.bounds.height)
        
        commentView = DCCommentView.init(scrollView: self.tableView, frame: self.tableView.bounds)
        commentView.delegate = self
        commentView.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        
        commentView.sendImage = UIImage(named: "send2")
        commentView.stickerImage = UIImage(named: "sticker")
        commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
        
        commentView.accessoryImage = UIImage(named: "attachment2")?.tint(tintColor: vkSingleton.shared.mainColor)
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
        
        if let gid = Int(self.groupID) {
            if vkSingleton.shared.commentFromGroup > 0 && vkSingleton.shared.commentFromGroup == abs(gid) {
                setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
            } else {
                setCommentFromGroupID(id: 0, controller: self)
            }
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(TopicCell.self, forCellReuseIdentifier: "topicCell")
        tableView.register(CommentCell.self, forCellReuseIdentifier: "commentCell")
        
        tableView.separatorStyle = .none
    }
    
    @objc func tapAccessoryButton(sender: UIButton) {
        commentView.endEditing(true)
        commentView.accessoryButton.buttonTouched()
        
        let selectView = SelectAttachPanel()
        
        selectView.delegate = self
        selectView.attachPanel = self.attachPanel
        selectView.button = self.commentView.accessoryButton
        
        selectView.ownerID = "-\(self.groupID)"
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
    
    @objc func tapFromGroupButton(sender: UIButton) {
        commentView.endEditing(true)
        commentView.fromGroupButton.buttonTouched()
        
        if attachPanel.editID == 0 {
            actionFromGroupButton(fromView: commentView.fromGroupButton)
        }
    }
    
    func didSendComment(_ text: String!) {
        commentView.endEditing(true)
        
        if attachPanel.editID == 0 {
            createComment(text: text, stickerID: 0)
        } else {
            editComment(text: text)
        }
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        if topics.count > 0 {
            let topic = topics[0]
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action1 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                
                let link = "https://vk.com/topic-\(self.groupID)_\(self.topicID)"
                    
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка на тему в обсуждениях:" , msg: "\(string)")
                }
            }
            alertController.addAction(action1)
            
            
            let action2 = UIAlertAction(title: "Добавить в «Избранное»", style: .default) { action in
                    
                self.addLinkToFave(object: topic)
            }
            alertController.addAction(action2)
            
            
            if group[0].isAdmin == 1 {
                let action3 = UIAlertAction(title: "Переименовать обсуждение", style: .default) { action in
                    
                    self.changeTitleTopic(oldTitle: topic.title)
                }
                alertController.addAction(action3)
                
                
                if topic.isFixed == 0 {
                    let action4 = UIAlertAction(title: "Закрепить обсуждение", style: .default) { action in
                        
                        self.fixTopic()
                    }
                    alertController.addAction(action4)
                } else {
                    let action4 = UIAlertAction(title: "Открепить обсуждение", style: .destructive) { action in
                        
                        self.fixTopic()
                    }
                    alertController.addAction(action4)
                }
                
                
                if topic.isClosed == 0 {
                    let action5 = UIAlertAction(title: "Запретить комментирование", style: .destructive) { action in
                        
                        self.closeTopic()
                    }
                    alertController.addAction(action5)
                } else {
                    let action5 = UIAlertAction(title: "Разрешить комментирование", style: .default) { action in
                        
                        self.closeTopic()
                    }
                    alertController.addAction(action5)
                }
        
                
                let action6 = UIAlertAction(title: "Удалить обсуждение", style: .destructive) { action in
                    
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
                    
                    alertView.addButton("Да, хочу удалить") {
                        
                        self.deleteTopic()
                    }
                    
                    alertView.addButton("Нет, я передумал") {}
                    
                    alertView.showWarning("Подтверждение!", subTitle: "Внимание! Данное действие необратимо.\nВы действительно хотите удалить данное обсуждение?")
                }
                alertController.addAction(action6)
            }
            
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.barButtonItem = self.navigationItem.rightBarButtonItem
                popoverController.permittedArrowDirections = [.up]
            }
            
            self.present(alertController, animated: true)
        }
    }
    
    func getTopicComments() {
        let opq = OperationQueue()
        
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator2(controller: self)
        }
        
        let url = "/method/board.getComments"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "topic_id": "\(topicID)",
            "need_likes": "1",
            "offset": "\(offset)",
            "count": "\(count)",
            "extended": "1",
            "sort": "desc",
            "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, last_name_dat, last_name_acc, sex",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseComments = ParseComments()
        parseComments.addDependency(getServerDataOperation)
        opq.addOperation(parseComments)
        
        let url2 = "/method/board.getTopics"
        let parameters2 = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "topic_ids": "\(topicID)",
            "extended": "1",
            "preview": "1",
            "preview_length": "0",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
        opq.addOperation(getServerDataOperation2)
        
        let parseTopics = ParseTopics()
        parseTopics.addDependency(getServerDataOperation2)
        opq.addOperation(parseTopics)
        
        let url3 = "/method/groups.getById"
        let parameters3 = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation3 = GetServerDataOperation(url: url3, parameters: parameters3)
        opq.addOperation(getServerDataOperation3)
        
        // парсим объект
        let parseGroupProfile = ParseGroupProfile()
        parseGroupProfile.addDependency(getServerDataOperation3)
        opq.addOperation(parseGroupProfile)
        
        let reloadController = ReloadTopicController(controller: self)
        reloadController.addDependency(parseComments)
        reloadController.addDependency(parseTopics)
        reloadController.addDependency(parseGroupProfile)
        OperationQueue.main.addOperation(reloadController)
    }
    
    @objc func loadMoreComments() {
        
        heights.removeAll(keepingCapacity: false)
        ViewControllerUtils().showActivityIndicator2(controller: self)
        
        let url = "/method/board.getComments"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "topic_id": "\(topicID)",
            "need_likes": "1",
            "offset": "\(offset)",
            "count": "\(count)",
            "extended": "1",
            "sort": "desc",
            "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, last_name_dat, last_name_acc, sex",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        
        let parseComments = ParseComments()
        parseComments.addDependency(getServerDataOperation)
        parseComments.completionBlock = {
            self.offset += self.count
            self.total = parseComments.count
            for comment in parseComments.comments {
                self.comments.append(comment)
            }
            for user in parseComments.users {
                self.users.append(user)
            }
            for group in parseComments.groups {
                self.groups.append(group)
            }
            
            OperationQueue.main.addOperation {
                self.attachPanel.comments = self.comments
                self.attachPanel.users = self.users
                self.attachPanel.groups = self.groups
                
                self.tableView.reloadData()
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 1, section: 1), at: .bottom, animated: true)
                }
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        OperationQueue().addOperation(parseComments)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return topics.count
        }
        if section == 1 {
            if comments.count > 0 {
                return comments.count + 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell") as! TopicCell
            
            if group.count > 0 {
                cell.delegate = self
                cell.topic = topics[indexPath.section]
                cell.group = group[0]
                cell.cellWidth = self.width
                
                return cell.configureCell(calc: true)
            }
            
            return 0
        case 1:
            if indexPath.row == 0 {
                if comments.count == total {
                    return 0
                }
                return 40
            } else {
                if let height = heights[indexPath] {
                    if self.attachPanel.editID > 0 {
                        return height - 20
                    }
                    return height
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
                    
                    cell.delegate = self
                    cell.comment = comments[comments.count - indexPath.row]
                    cell.cellWidth = self.width
                    
                    let height = cell.getRowHeight()
                    heights[indexPath] = height
                    
                    return height
                }
            }
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = UIColor(displayP3Red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath) as! TopicCell
            
            if group.count > 0 {
                cell.delegate = self
                cell.topic = topics[0]
                cell.group = group[0]
                cell.users = topicUsers
                
                cell.cellWidth = self.width
                cell.indexPath = indexPath
                cell.cell = cell
                cell.tableView = self.tableView
                
                let _ = cell.configureCell(calc: false)
            }
            
            cell.selectionStyle = .none
            
            return cell
        case 1:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
                
                if comments.count < total {
                    var count = self.count
                    if count > total - comments.count {
                        count = total - comments.count
                    }
                    cell.cellWidth = self.width
                    cell.configureCountCell(count: count, total: total - comments.count)
                    cell.countButton.addTarget(self, action: #selector(loadMoreComments), for: .touchUpInside)
                } else {
                    cell.removeAllSubviews()
                }
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 20)
                cell.selectionStyle = .none
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
                
                let comment = comments[comments.count - indexPath.row]
                
                cell.delegate = self
                cell.editID = self.attachPanel.editID
                
                cell.indexPath = indexPath
                cell.cell = cell
                cell.tableView = self.tableView
                cell.comment = comment
                cell.users = users
                cell.groups = groups
                
                if topics.count > 0 {
                    if topics[0].isClosed == 1 {
                        cell.canComment = 0
                    }
                }
                
                cell.cellWidth = self.width
                
                cell.configureCell()
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 20 + cell.avatarHeight, bottom: 0, right: 20)
                cell.selectionStyle = .none
                
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
    }
    
    func createComment(text: String, stickerID: Int) {
        let url = "/method/board.createComment"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": self.groupID,
            "topic_id": self.topicID,
            "message": text,
            "attachments": self.attachPanel.attachments,
            "v": vkSingleton.shared.version
        ]
        
        if vkSingleton.shared.commentFromGroup > 0 {
            parameters["from_group"] = "\(vkSingleton.shared.commentFromGroup)"
        }
        
        if stickerID > 0 {
            parameters["sticker_id"] = "\(stickerID)"
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
                    self.offset = 0
                    self.comments.removeAll(keepingCapacity: false)
                    self.users.removeAll(keepingCapacity: false)
                    self.groups.removeAll(keepingCapacity: false)
                    
                    self.commentView.textView.text = ""
                    
                    self.attachPanel.attachArray.removeAll(keepingCapacity: false)
                    self.attachPanel.editID = 0
                    self.attachPanel.replyID = 0
                    
                    if self.topics.count > 0 {
                        self.topics[0].commentsCount += 1
                    }
                    
                    self.loadMoreComments()
                }
            } else if error.errorCode == 15 && vkSingleton.shared.commentFromGroup > 0 {
                self.showErrorMessage(title: "Ошибка", msg: "ВКонтакте закрыл доступ для отправки комментариев от имени малочисленных и недавно созданных групп. Попробуйте отправить комментарий от имени данного сообщества позднее.")
            } else if error.errorCode == 213 {
                self.showErrorMessage(title: "Ошибка", msg: "\nНет доступа к комментированию записи.\n")
            } else if error.errorCode == 223 {
                self.showErrorMessage(title: "Ошибка", msg: "\nПревышен лимит комментариев на стене.\n")
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func editComment(text: String) {
        
        let url = "/method/board.editComment"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": self.groupID,
            "topic_id": self.topicID,
            "comment_id": "\(self.attachPanel.editID)",
            "message": text,
            "attachments": self.attachPanel.attachments,
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
                    self.offset = 0
                    self.comments.removeAll(keepingCapacity: false)
                    self.users.removeAll(keepingCapacity: false)
                    self.groups.removeAll(keepingCapacity: false)
                    
                    self.commentView.textView.text = ""
                    
                    self.attachPanel.attachArray.removeAll(keepingCapacity: false)
                    self.attachPanel.editID = 0
                    self.attachPanel.replyID = 0
                    
                    self.loadMoreComments()
                }
            } else {
                OperationQueue.main.addOperation {
                    self.commentView.textView.text = text
                    self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
                }
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func deleteComment(commentID: String) {
        
        let url = "/method/board.deleteComment"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": self.groupID,
            "topic_id": self.topicID,
            "comment_id": commentID,
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
                    self.offset = 0
                    self.comments.removeAll(keepingCapacity: false)
                    self.users.removeAll(keepingCapacity: false)
                    self.groups.removeAll(keepingCapacity: false)
                    
                    if self.topics.count > 0 {
                        self.topics[0].commentsCount -= 1
                    }
                    
                    self.loadMoreComments()
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    @objc func cancelEditMode(sender: UIBarButtonItem) {
        self.title = "Обсуждение"
        if self.topics.count > 0 {
            self.title = "Обсуждение «\(self.topics[0].title)»"
        }
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItem(sender:)))
        self.navigationItem.rightBarButtonItem = barButton
        
        self.setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
        self.commentView.textView.text = ""
        
        self.attachPanel.attachArray.removeAll(keepingCapacity: false)
        self.attachPanel.editID = 0
        self.attachPanel.replyID = 0
        
        self.tableView.reloadData()
    }
    
    func changeTitleTopic(oldTitle: String) {
        
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 32.0,
            kWindowWidth: 300,
            kTitleFont: UIFont(name: "Verdana-Bold", size: 14)!,
            kTextFont: UIFont(name: "Verdana", size: 15)!,
            kButtonFont: UIFont(name: "Verdana", size: 16)!,
            showCloseButton: false
        )
        
        let alert = SCLAlertView(appearance: appearance)
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 274, height: 100))
        
        textView.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 5
        textView.backgroundColor = UIColor.init(red: 242/255, green: 242/255, blue: 242/255, alpha: 0.75)
        textView.font = UIFont(name: "Verdana", size: 13)
        textView.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        textView.text = oldTitle
        
        alert.customSubview = textView
        
        alert.addButton("Сохранить", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
            if let text = textView.text {
                self.editTopic(newTitle: text)
            }
        }
        
        alert.addButton("Отмена", backgroundColor: UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1), textColor: UIColor.white) {
            
        }
        
        alert.showInfo("", subTitle: "", closeButtonTitle: "Сохранить")
    }
}
