//
//  VideoController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 23.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit
import DCCommentView
import SCLAlertView

class VideoController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate, DCCommentViewDelegate {
    
    var vid = ""
    var ownerID = ""
    var offset = 0
    var count = 30
    var totalComments = 0
    var accessKey = ""
    
    var video: [Video] = []
    var users: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    var likes: [Likes] = []
    var reposts: [Likes] = []
    
    var comments: [Comment] = []
    var commentsProfiles: [UserProfile] = []
    var commentsGroups: [GroupProfile] = []
    
    var tableView = UITableView()
    var commentView: DCCommentView!
    
    var attachPanel = AttachPanel()
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var heights: [IndexPath: CGFloat] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.attachPanel.delegate = self
            self.configureTableView()
            
            let barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItem(sender:)))
            self.navigationItem.rightBarButtonItem = barButton
            
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        getVideo()
        StoreReviewHelper.checkAndAskForReview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func configureTableView() {
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        commentView = DCCommentView.init(scrollView: self.tableView, frame: self.view.bounds)
        commentView.delegate = self
        commentView.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        
        commentView.sendImage = UIImage(named: "send2")
        commentView.stickerImage = UIImage(named: "sticker")
        commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
        
        if let id = Int(self.ownerID) {
            if vkSingleton.shared.commentFromGroup > 0 && vkSingleton.shared.commentFromGroup == abs(id) {
                setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
            } else {
                setCommentFromGroupID(id: 0, controller: self)
            }
        }
        
        commentView.accessoryImage = UIImage(named: "attachment2")?.tint(tintColor: vkSingleton.shared.mainColor)
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        
        tableView.register(VideoCell.self, forCellReuseIdentifier: "videoCell")
        tableView.register(CommentCell.self, forCellReuseIdentifier: "commentCell")
    }
    
    @objc func tapAccessoryButton(sender: UIButton) {
        commentView.endEditing(true)
        commentView.accessoryButton.buttonTouched()
        
        let selectView = SelectAttachPanel()
        
        selectView.delegate = self
        selectView.attachPanel = self.attachPanel
        selectView.button = self.commentView.accessoryButton
        
        selectView.ownerID = self.ownerID
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
    
    func getVideo() {
        
         var code = "var a = API.video.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(self.ownerID)\",\"videos\":\"\(ownerID)_\(vid)_\(accessKey)\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, photo_100\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var b = API.likes.getList({\"type\":\"video\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(ownerID)\",\"item_id\":\"\(vid)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, photo_100, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\": \"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var c = API.video.getComments({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(ownerID)\",\"video_id\":\"\(vid)\",\"need_likes\":\"1\",\"offset\":\"\(offset)\",\"count\":\"\(count)\",\"sort\":\"desc\",\"preview_length\":\"0\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, last_name_dat, last_name_acc, sex\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var d = API.likes.getList({\"type\":\"video\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(ownerID)\",\"item_id\":\"\(vid)\",\"filter\":\"copies\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, photo_100, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) return [a,b,c,d];"
        
        let url = "/method/execute"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "code": code,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json["response"][0]["items"])
            
            let video = json["response"][0]["items"].compactMap { Video(json: $0.1) }
            let videoProfiles = json["response"][0]["profiles"].compactMap { UserProfile(json: $0.1) }
            let videoGroups = json["response"][0]["groups"].compactMap { GroupProfile(json: $0.1) }
            
            let likes = json["response"][1]["items"].compactMap { Likes(json: $0.1) }
            
            let comments = json["response"][2]["items"].compactMap { Comment(json: $0.1) }
            let commentsProfiles = json["response"][2]["profiles"].compactMap { UserProfile(json: $0.1) }
            let commentsGroups = json["response"][2]["groups"].compactMap { GroupProfile(json: $0.1) }
            let commentsCount = json["response"][2]["count"].intValue
            
            let reposts = json["response"][3]["items"].compactMap { Likes(json: $0.1) }
            
            OperationQueue.main.addOperation {
                self.video = video
                self.groups = videoGroups
                self.users = videoProfiles
                
                self.likes = likes
                self.reposts = reposts
                
                self.totalComments = commentsCount
                if self.offset == 0 {
                    self.comments = comments
                    self.commentsGroups = commentsGroups
                    self.commentsProfiles = commentsProfiles
                } else {
                    for comment in comments {
                        self.comments.append(comment)
                    }
                    for profile in commentsProfiles {
                        self.commentsProfiles.append(profile)
                    }
                    for group in commentsGroups {
                        self.commentsGroups.append(group)
                    }
                }
                
                if self.video.count > 0 {
                    if self.video[0].canComment == 0 {
                        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
                        self.view.addSubview(self.tableView)
                        self.commentView.removeFromSuperview()
                    } else {
                        self.view.addSubview(self.commentView)
                    }
                    
                    let barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                    self.navigationItem.rightBarButtonItem = barButton
                }
                
                self.attachPanel.comments = self.comments
                self.attachPanel.users = self.commentsProfiles
                self.attachPanel.groups = self.commentsGroups
                
                self.offset += self.count
                self.tableView.reloadData()
                self.tableView.separatorStyle = .singleLine
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        queue.addOperation(getServerDataOperation)
    }
    
    @objc func loadMoreComments() {
        
        heights.removeAll(keepingCapacity: false)
        
        let url = "/method/video.getComments"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": ownerID,
            "video_id": vid,
            "need_likes": "1",
            "offset": "\(offset)",
            "count": "\(count)",
            "sort": "desc",
            "extended": "1",
            "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, last_name_dat, last_name_acc, sex",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let comments = json["response"]["items"].compactMap { Comment(json: $0.1) }
            let profiles = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
            let groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
            
            self.offset += self.count
            self.totalComments = json["response"]["count"].intValue
            for comment in comments {
                self.comments.append(comment)
            }
            for profile in profiles {
                self.commentsProfiles.append(profile)
            }
            for group in groups {
                self.commentsGroups.append(group)
            }
            
            OperationQueue.main.addOperation {
                self.attachPanel.comments = self.comments
                self.attachPanel.users = self.commentsProfiles
                self.attachPanel.groups = self.commentsGroups
                
                self.tableView.reloadData()
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 1, section: 1), at: .bottom, animated: true)
                }
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if video.count > 0 {
                return 1
            }
            return 0
        }
        
        if section == 1 {
            if comments.count > 0 {
                return comments.count + 1
            }
            return 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < video.count {
            if let height = heights[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoCell
                
                cell.delegate = self
                cell.video = self.video[0]
                cell.cellWidth = self.tableView.frame.width
                
                let height = cell.getRowHeight()
                heights[indexPath] = height
                return height
            }
        } else {
            if indexPath.row == 0 {
                if comments.count == totalComments {
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
                    cell.cellWidth = self.tableView.frame.width
                    
                    
                    let height = cell.getRowHeight()
                    heights[indexPath] = height
                    
                    return height
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < video.count {
            if let height = heights[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoCell
                
                cell.delegate = self
                cell.video = self.video[0]
                cell.cellWidth = self.tableView.frame.width
                
                let height = cell.getRowHeight()
                heights[indexPath] = height
                return height
            }
        } else {
            if indexPath.row == 0 {
                if comments.count == totalComments {
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
                    cell.cellWidth = self.tableView.frame.width
                    
                    
                    let height = cell.getRowHeight()
                    heights[indexPath] = height
                    
                    return height
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if video.count > 0 {
                return 5
            }
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            if video.count > 0 {
                return 5
            }
        }
        if section == 1 {
            if comments.count > 0 {
                return 5
            }
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = vkSingleton.shared.backColor
        
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = vkSingleton.shared.backColor
        
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section < self.video.count {
            let video = self.video[indexPath.section]
            
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoCell
            
            cell.delegate = self
            cell.indexPath = indexPath
            cell.cell = cell
            cell.tableView = self.tableView
            
            cell.video = video
            cell.users = users
            cell.groups = groups
            
            cell.likes = likes
            cell.reposts = reposts
            
            cell.cellWidth = self.tableView.frame.width
            
            cell.configureCell()
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
                
                if comments.count < totalComments {
                    var count = self.count
                    if count > totalComments - comments.count {
                        count = totalComments - comments.count
                    }
                    cell.cellWidth = self.tableView.frame.width
                    cell.configureCountCell(count: count, total: totalComments - comments.count)
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
                cell.users = commentsProfiles
                cell.groups = commentsGroups
                
                cell.cellWidth = self.tableView.frame.width
                
                cell.configureCell()
                
                if comment.replyComment != 0 {
                    let tapReply = UITapGestureRecognizer(target: self, action: #selector(showReplyComment(sender:)))
                    cell.dateLabel.isUserInteractionEnabled = true
                    cell.dateLabel.addGestureRecognizer(tapReply)
                }
                
                cell.separatorInset = UIEdgeInsets(top: 0, left: 20 + cell.avatarHeight, bottom: 0, right: 20)
                cell.selectionStyle = .none
                
                return cell
            }
        }
    }
    
    @objc func showReplyComment(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let buttonPosition: CGPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                
                commentView.endEditing(true)
                
                let index = comments.count - indexPath.row
                let comment = comments[index]
                
                let url = "/method/video.getComments"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": ownerID,
                    "video_id": vid,
                    "start_comment_id": "\(comment.replyComment)",
                    "count": "1",
                    "preview_length": "0",
                    "extended": "1",
                    "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, last_name_dat, last_name_acc, sex",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                getServerDataOperation.completionBlock = {
                    guard let data = getServerDataOperation.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    //print(json)
                    
                    let reply = json["response"]["items"].compactMap { Comment(json: $0.1) }
                    let users = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
                    let groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
                    
                    if reply.count > 0 {
                        var name = ""
                        if reply[0].fromID > 0 {
                            let user = users.filter({ $0.uid == "\(reply[0].fromID)" })
                            if user.count > 0 {
                                if user[0].sex == 1 {
                                    name = "\(user[0].firstName) \(user[0].lastName) написала"
                                } else {
                                    name = "\(user[0].firstName) \(user[0].lastName) написал"
                                }
                            }
                        } else {
                            let group = groups.filter({ $0.gid == abs(reply[0].fromID) })
                            if group.count > 0 {
                                name = "\(group[0].name) написал"
                            }
                        }
                        
                        var text = reply[0].text.prepareTextForPublic()
                        if reply[0].attachments.count > 0 {
                            if reply[0].attachments.count == 1 {
                                let aType = reply[0].attachments[0].type
                                if aType == "photo" {
                                    if text != "" {
                                        text = "\(text)\n[Фотография]"
                                    } else {
                                        text = "[Фотография]"
                                    }
                                } else if aType == "video" {
                                    if text != "" {
                                        text = "\(text)\n[Видеозапись]"
                                    } else {
                                        text = "[Видеозапись]"
                                    }
                                } else if aType == "sticker" {
                                    if text != "" {
                                        text = "\(text)\n[Стикер]"
                                    } else {
                                        text = "[Стикер]"
                                    }
                                } else if aType == "doc" {
                                    if text != "" {
                                        text = "\(text)\n[Документ]"
                                    } else {
                                        text = "[Документ]"
                                    }
                                } else if aType == "audio" {
                                    if text != "" {
                                        text = "\(text)\n[Аудиозапись]"
                                    } else {
                                        text = "[Аудиозапись]"
                                    }
                                }
                            } else {
                                if text != "" {
                                    text = "\(text)\n[\(reply[0].attachments.count.attachAdder())]"
                                } else {
                                    text = "[\(reply[0].attachments.count.attachAdder())]"
                                }
                            }
                        }
                        
                        self.showInfoMessage(title: "\(reply[0].date.toStringLastTime())\n\(name):", msg: "\n\(text)\n")
                    } else {
                        
                        self.showErrorMessage(title: "Ошибка", msg: "Увы, комментарий, на который отвечали, уже удален.☹️")
                    }
                }
                OperationQueue().addOperation(getServerDataOperation)
            }
        }
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
        if video.count > 0 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let video = self.video[0]
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action1 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                
                let link = "https://vk.com/video\(self.ownerID)_\(self.vid)"
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка на видеозапись:" , msg: "\(string)")
                }
            }
            alertController.addAction(action1)
            
            
            let action2 = UIAlertAction(title: "Добавить в «Избранное»", style: .default) { action in
                
                self.addLinkToFave(object: video)
            }
            alertController.addAction(action2)
            
            
            if video.canAdd == 1 {
                let action3 = UIAlertAction(title: "Добавить в «Мои видеозаписи»", style: .default) { action in
                    
                    video.addToFaveVideos(delegate: self)
                }
                alertController.addAction(action3)
            }
            
            let action4 = UIAlertAction(title: "Удалить из «Мои видеозаписи»", style: .destructive) { action in
                
                video.deleteFromFaveVideos(delegate: self)
            }
            alertController.addAction(action4)
            
            
            if "\(video.ownerID)" == vkSingleton.shared.userID {
                let action5 = UIAlertAction(title: "Удалить видеозапись", style: .destructive) { action in
                    
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
                        
                        video.deleteFromSite(delegate: self)
                    }
                    
                    alertView.addButton("Нет, я передумал") {}
                    
                    alertView.showWarning("Подтверждение!", subTitle: "Внимание! Данное действие необратимо.\nВы действительно хотите удалить эту видеозапись с сайта ВКонтакте?")
                }
                alertController.addAction(action5)
            }
            
            
            let action6 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                
                
            }
            alertController.addAction(action6)
            
            
            if let popoverController = alertController.popoverPresentationController, let barButton = self.navigationItem.rightBarButtonItem {
                popoverController.barButtonItem = barButton
                popoverController.permittedArrowDirections = [.up]
            }
            
            present(alertController, animated: true)
        }
    }
    
    func createComment(text: String, stickerID: Int) {
        let url = "/method/video.createComment"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": self.ownerID,
            "video_id": self.vid,
            "message": text,
            "attachments": self.attachPanel.attachments,
            "v": vkSingleton.shared.version
        ]
        
        if vkSingleton.shared.commentFromGroup > 0 {
            parameters["from_group"] = "\(vkSingleton.shared.commentFromGroup)"
        }
        
        if self.attachPanel.replyID > 0 {
            parameters["reply_to_comment"] = "\(self.attachPanel.replyID)"
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
                    self.commentsProfiles.removeAll(keepingCapacity: false)
                    self.commentsGroups.removeAll(keepingCapacity: false)
                    
                    self.commentView.textView.text = ""
                    
                    self.attachPanel.attachArray.removeAll(keepingCapacity: false)
                    self.attachPanel.editID = 0
                    self.attachPanel.replyID = 0
                    
                    if self.video.count > 0 {
                        self.video[0].comments += 1
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
        
        let url = "/method/video.editComment"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": self.ownerID,
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
                    self.commentsProfiles.removeAll(keepingCapacity: false)
                    self.commentsGroups.removeAll(keepingCapacity: false)
                    
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
        
        let url = "/method/video.deleteComment"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": self.ownerID,
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
                    self.commentsProfiles.removeAll(keepingCapacity: false)
                    self.commentsGroups.removeAll(keepingCapacity: false)
                    
                    if self.video.count > 0 {
                        self.video[0].comments -= 1
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
        self.title = "Видеозапись"
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItem(sender:)))
        self.navigationItem.rightBarButtonItem = barButton
        
        self.setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
        self.commentView.textView.text = ""
        
        self.attachPanel.attachArray.removeAll(keepingCapacity: false)
        self.attachPanel.editID = 0
        self.attachPanel.replyID = 0
        
        self.tableView.reloadData()
    }
}
