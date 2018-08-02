//
//  RecordController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 20.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit
import DCCommentView
import Popover

class RecordController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate, DCCommentViewDelegate {
    
    var delegate: UIViewController!
    var heights: [IndexPath: CGFloat] = [:]
    
    var tableView = UITableView()
    var commentView: DCCommentView!
    
    var uid = 0
    var pid = 0
    var accessKey = ""
    
    var type = "post"
    var record: [Record] = []
    var users: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    var likes: [Likes] = []
    var reposts: [Likes] = []
    
    var comments: [Comment] = []
    var commentsProfiles: [UserProfile] = []
    var commentsGroups: [GroupProfile] = []
    
    var photo: Photo!
    
    var count = 30
    var offset = 0
    var totalComments = 0
    
    var attachPanel = AttachPanel()
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        OperationQueue.main.addOperation {
            self.attachPanel.delegate = self
            self.configureTableView()
            
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        getRecord()
        StoreReviewHelper.checkAndAskForReview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureTableView() {
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        commentView = DCCommentView(scrollView: self.tableView, frame: self.tableView.bounds)
        commentView.delegate = self
        commentView.tintColor = vkSingleton.shared.mainColor
        
        commentView.sendImage = UIImage(named: "send2")
        commentView.stickerImage = UIImage(named: "sticker")
        commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
        
        commentView.accessoryImage = UIImage(named: "attachment")
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
        
        setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(RecordCell.self, forCellReuseIdentifier: "recordCell")
        tableView.register(CommentCell.self, forCellReuseIdentifier: "commentCell")
    }

    @objc func tapAccessoryButton(sender: UIButton) {
        commentView.endEditing(true)
        commentView.accessoryButton.buttonTouched()
        
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
        
        actionFromGroupButton(fromView: commentView.fromGroupButton)
    }
    
    func didSendComment(_ text: String!) {
        commentView.endEditing(true)
        createComment(text: text, attachments: attachPanel.attachments, replyID: attachPanel.replyID, stickerID: 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if record.count > 0 {
                return 1
            }
        }
        
        if section == 1 {
            if comments.count > 0 {
                return comments.count + 1
            }
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let height = heights[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! RecordCell
                
                cell.delegate = self
                cell.record = record[0]
                cell.cellWidth = self.tableView.frame.width
                cell.showLikesPanel = true
                
                cell.likes = likes
                cell.reposts = reposts
                
                let height = cell.getRowHeight()
                heights[indexPath] = height
                
                return height
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if let height = heights[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! RecordCell
                
                cell.delegate = self
                cell.record = record[0]
                cell.cellWidth = self.tableView.frame.width
                cell.showLikesPanel = true
                
                cell.likes = likes
                cell.reposts = reposts
                
                let height = cell.getRowHeight()
                heights[indexPath] = height
                
                return height
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                if comments.count == totalComments {
                    return 0
                }
                return 40
            } else {
                if let height = heights[indexPath] {
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
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if record.count > 0 {
                return 5
            }
        }
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            if record.count > 0 {
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
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordCell
            
            cell.delegate = self
            cell.indexPath = indexPath
            cell.cell = cell
            cell.tableView = self.tableView
            cell.showLikesPanel = true
            
            cell.record = record[0]
            cell.users = users
            cell.groups = groups
            
            cell.likes = likes
            cell.reposts = reposts
            
            cell.cellWidth = self.tableView.frame.width
            
            cell.configureCell()
            cell.selectionStyle = .none
            
            return cell
        }
        
        if indexPath.section == 1 {
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
    func getRecord() {
        
        heights.removeAll(keepingCapacity: false)
        
        if type == "post" {
            
            var code = "var a = API.wall.getById({\"posts\":\"\(uid)_\(pid)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"extended\":\"1\",\"copy_history_depth\":\"3\",\"fields\":\"id,first_name,first_name_gen,last_name,last_name_gen,photo_max,photo_100\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var b = API.likes.getList({\"type\":\"post\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(uid)\",\"item_id\":\"\(pid)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, photo_100, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\": \"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var c = API.wall.getComments({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(uid)\",\"post_id\":\"\(pid)\",\"need_likes\":\"1\",\"offset\":\"\(offset)\",\"count\":\"\(count)\",\"sort\":\"desc\",\"preview_length\":\"0\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, last_name_dat, last_name_acc, sex\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var d = API.likes.getList({\"type\":\"post\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(uid)\",\"item_id\":\"\(pid)\",\"filter\":\"copies\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, photo_100, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            
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
                //print(json["response"][2]["items"])
                
                let record = json["response"][0]["items"].compactMap { Record(json: $0.1) }
                let recordProfiles = json["response"][0]["profiles"].compactMap { UserProfile(json: $0.1) }
                let recordGroups = json["response"][0]["groups"].compactMap { GroupProfile(json: $0.1) }
                
                let likes = json["response"][1]["items"].compactMap { Likes(json: $0.1) }
                
                let comments = json["response"][2]["items"].compactMap { Comment(json: $0.1) }
                let commentsProfiles = json["response"][2]["profiles"].compactMap { UserProfile(json: $0.1) }
                let commentsGroups = json["response"][2]["groups"].compactMap { GroupProfile(json: $0.1) }
                let commentsCount = json["response"][2]["count"].intValue
                
                let reposts = json["response"][3]["items"].compactMap { Likes(json: $0.1) }
                
                OperationQueue.main.addOperation {
                    self.record = record
                    self.groups = recordGroups
                    self.users = recordProfiles
                    
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
                    
                    
                    self.title = "Запись"
                    
                    if self.record.count > 0 {
                        if self.record[0].canComment == 0 {
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
        } else if type == "photo" {
            
            var code = "var a = API.photos.getById({\"photos\":\"\(uid)_\(pid)_\(accessKey)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"extended\":\"1\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var b = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(uid)\",\"item_id\":\"\(pid)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, photo_100, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\": \"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var c = API.photos.getComments({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(uid)\",\"photo_id\":\"\(pid)\",\"need_likes\":\"1\",\"offset\":\"\(offset)\",\"count\":\"\(count)\",\"sort\":\"desc\",\"preview_length\":\"0\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, last_name_dat, last_name_acc, sex\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var d = API.likes.getList({\"type\":\"photo\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(uid)\",\"item_id\":\"\(pid)\",\"filter\":\"copies\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, photo_100, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            if self.uid > 0 {
                code = "\(code) var e = API.users.get({\"user_id\":\"\(uid)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"fields\":\"id, first_name, last_name, photo_max_orig, photo_max, photo_100\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            } else if uid < 0{
                code = "\(code) var e = API.groups.getById({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"group_id\":\"\(abs(uid))\",\"fields\":\"activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_hidden_from_feed\",\"v\": \"\(vkSingleton.shared.version)\"}); \n"
            }
            
            code = "\(code) return [a,b,c,d,e];"
            
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
                //print(json["response"][0])
                
                let photos = json["response"][0].compactMap { Photo(json: $0.1) }
                
                let likes = json["response"][1]["items"].compactMap { Likes(json: $0.1) }
                
                let comments = json["response"][2]["items"].compactMap { Comment(json: $0.1) }
                let commentsProfiles = json["response"][2]["profiles"].compactMap { UserProfile(json: $0.1) }
                let commentsGroups = json["response"][2]["groups"].compactMap { GroupProfile(json: $0.1) }
                let commentsCount = json["response"][2]["count"].intValue
                
                let reposts = json["response"][3]["items"].compactMap { Likes(json: $0.1) }
                
                if self.uid > 0 {
                    let profiles = json["response"][4].compactMap { UserProfile(json: $0.1) }
                    
                    for user in profiles {
                        self.users.append(user)
                    }
                } else if self.uid < 0{
                    let profiles = json["response"][4].compactMap { GroupProfile(json: $0.1) }
                    
                    for group in profiles {
                        self.groups.append(group)
                    }
                }
                
                OperationQueue.main.addOperation {
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
                    self.totalComments = commentsCount
                    
                    if photos.count > 0 {
                        let record = Record(json: JSON.null)
                        let photo = photos[0]
                        photo.accessKey = self.accessKey
                        
                        record.id = photo.id
                        record.ownerID = photo.ownerID
                        record.fromID = photo.ownerID
                        record.createdBy = photo.userID
                        record.date = photo.date
                        record.commentsCount = photo.commentsCount
                        record.canComment = photo.canComment
                        record.likesCount = photo.likesCount
                        record.userLikes = photo.userLikes
                        record.userCanRepost = photo.userCanRepost
                        record.repostCount = photo.repostCount
                        record.userReposted = photo.userReposted
                        
                        record.text = photo.text
                        record.postType = "post"
                        
                        let attach = Attachment(json: JSON.null)
                        attach.photo.append(photo)
                        record.attachments.append(attach)
                        
                        self.record.append(record)
                    }
                    self.title = "Фотография"
                    
                    if self.record.count > 0 {
                        if self.record[0].canComment == 0 {
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
    }
    
    @objc func loadMoreComments() {
        
        var url = ""
        var parameters = ["":""]
        
        heights.removeAll(keepingCapacity: false)
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        if type == "post" {
            url = "/method/wall.getComments"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": "\(uid)",
                "post_id": "\(pid)",
                "need_likes": "1",
                "offset": "\(offset)",
                "count": "\(count)",
                "sort": "desc",
                "preview_length": "0",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, last_name_dat, last_name_acc, sex",
                "v": vkSingleton.shared.version
            ]
        } else if type == "photo" {
            url = "/method/photos.getComments"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": "\(uid)",
                "photo_id": "\(pid)",
                "need_likes": "1",
                "offset": "\(offset)",
                "count": "\(count)",
                "sort": "desc",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, last_name_dat, last_name_acc, sex",
                "v": vkSingleton.shared.version
            ]
        }
        
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
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    @objc func showReplyComment(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let buttonPosition: CGPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                
                commentView.endEditing(true)
                
                let index = comments.count - indexPath.row
                let comment = comments[index]
                
                //self.commentView.endEditing(true)
                
                var url = "/method/wall.getComments"
                var parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": "\(uid)",
                    "post_id": "\(pid)",
                    "start_comment_id": "\(comment.replyComment)",
                    "count": "1",
                    "preview_length": "0",
                    "extended": "1",
                    "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, last_name_dat, last_name_acc, sex",
                    "v": vkSingleton.shared.version
                ]
                
                if self.type == "photo" {
                    url = "/method/photos.getComments"
                    parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": "\(uid)",
                        "photo_id": "\(pid)",
                        "start_comment_id": "\(comment.replyComment)",
                        "count": "1",
                        "preview_length": "0",
                        "extended": "1",
                        "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, last_name_dat, last_name_acc, sex",
                        "v": vkSingleton.shared.version
                    ]
                }
                
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
        
    }
    
    func createComment(text: String, attachments: String, replyID: Int, stickerID: Int) {
        var url = ""
        var parameters: Parameters = [:]
        
        
        parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": self.uid,
            "message": text,
            "attachments": attachments,
            "v": vkSingleton.shared.version
        ]
        
        if self.type == "post" {
            url = "/method/wall.createComment"
            parameters["post_id"] = self.pid
        } else if self.type == "photo" {
            url = "/method/photos.createComment"
            parameters["photo_id"] = self.pid
        }
        
        if vkSingleton.shared.commentFromGroup > 0 {
            parameters["from_group"] = "\(vkSingleton.shared.commentFromGroup)"
        }
        
        if replyID > 0 {
            parameters["reply_to_comment"] = "\(replyID)"
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
                    
                    self.attachPanel.attachments = ""
                    self.attachPanel.replyID = 0
                    
                    if self.record.count > 0 {
                        self.record[0].commentsCount += 1
                    }
                    
                    self.loadMoreComments()
                    self.commentView.becomeFirstResponder()
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
    
    func deleteComment(commentID: String) {
        
        var url = "/method/wall.deleteComment"
        if self.type == "photo" {
            url = "/method/photos.deleteComment"
        }
        
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": "\(self.uid)",
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
                    
                    if self.record.count > 0 {
                        self.record[0].commentsCount -= 1
                    }
                    
                    self.loadMoreComments()
                    self.commentView.becomeFirstResponder()
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
}
