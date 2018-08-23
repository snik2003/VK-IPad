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
import SCLAlertView

class RecordController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate, DCCommentViewDelegate {
    
    var delegate: UIViewController!
    var heights: [IndexPath: CGFloat] = [:]
    
    var tableView = UITableView()
    var commentView: DCCommentView!
    var barButton: UIBarButtonItem!
    
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
    var preview = false
    
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
            
            if self.preview {
                self.title = "Предварительный просмотр"
                self.view.addSubview(self.tableView)
                
                self.tableView.reloadData()
                ViewControllerUtils().hideActivityIndicator()
            } else {
                self.getRecord()
                StoreReviewHelper.checkAndAskForReview()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureTableView() {
        tableView.frame = CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height)
        
        if !preview {
            commentView = DCCommentView(scrollView: self.tableView, frame: self.tableView.bounds)
            commentView.delegate = self
            commentView.tintColor = vkSingleton.shared.mainColor
            
            commentView.sendImage = UIImage(named: "send2")
            commentView.stickerImage = UIImage(named: "sticker")
            commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
            
            commentView.accessoryImage = UIImage(named: "attachment2")?.tint(tintColor: vkSingleton.shared.mainColor)
            commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
            
            setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
        } else {
            commentView = DCCommentView()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(RecordCell.self, forCellReuseIdentifier: "recordCell")
        tableView.register(CommentCell.self, forCellReuseIdentifier: "commentCell")
    }

    @objc func tapAccessoryButton(sender: UIButton) {
        commentView.endEditing(true)
        commentView.accessoryButton.buttonTouched()
        
        let selectView = SelectAttachPanel()
        
        selectView.delegate = self
        selectView.attachPanel = self.attachPanel
        selectView.button = self.commentView.accessoryButton
        
        selectView.ownerID = "\(self.uid)"
        
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
                if preview {
                    cell.showLikesPanel = false
                }
                
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
                if preview {
                    cell.showLikesPanel = false
                }
                
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
            if preview {
                cell.showLikesPanel = false
            }
            
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
                cell.editID = self.attachPanel.editID
                
                cell.indexPath = indexPath
                cell.cell = cell
                cell.tableView = self.tableView
                cell.comment = comment
                cell.users = commentsProfiles
                cell.groups = commentsGroups
                
                if record.count > 0 {
                    cell.canComment = record[0].canComment
                }
                
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
                //print(json["response"][0]["items"])
                
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
                        if self.record[0].postType == "postpone" {
                            self.title = "Отложенная запись (не опубликована)"
                        }
                        
                        if self.record[0].postType == "suggest" {
                            self.title = "Предложенная запись (не опубликована)"
                        }
                        
                        if self.record[0].canComment == 0 {
                            self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
                            self.view.addSubview(self.tableView)
                            self.commentView.removeFromSuperview()
                        } else {
                            self.view.addSubview(self.commentView)
                        }
                        
                        self.barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                        self.navigationItem.rightBarButtonItem = self.barButton
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
                        self.photo = photo
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
                        
                        self.barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItem(sender:)))
                        self.navigationItem.rightBarButtonItem = self.barButton
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
        
        let record = self.record[0]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        var title = ""
        var style: UIAlertActionStyle = .default
        
        let action1 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
            
            if self.type == "post" {
                let link = "https://vk.com/wall\(record.ownerID)_\(record.id)"
                
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка на пост:" , msg: "\(string)")
                }
            } else if self.type == "photo" {
                let link = "https://vk.com/photo\(record.ownerID)_\(record.id)"
                
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка на фотографию:" , msg: "\(string)")
                }
            }
        }
        alertController.addAction(action1)
        
        
        if record.postType != "postpone" && record.postType != "suggest" {
            let action2 = UIAlertAction(title: "Добавить в «Избранное»", style: .default) { action in
            
                self.addLinkToFave(object: record)
            }
            alertController.addAction(action2)
        }
        
        
        if self.type == "photo" {
            if let photo = self.photo {
                let action1 = UIAlertAction(title: "Сохранить в личном профиле", style: .default) { action in
                    
                    photo.copyToSaveAlbum(delegate: self)
                }
                alertController.addAction(action1)
                
                let action2 = UIAlertAction(title: "Сохранить в памяти устройства", style: .default) { action in
                    
                    photo.saveToDevice(delegate: self)
                }
                alertController.addAction(action2)
            }
        }
        
        
        if record.canPin == 1 {
            if record.isPinned == 0 {
                title = "Закрепить на стене"
                style = .default
            } else {
                title = "Открепить на стене"
                style = .destructive
            }
            
            let action3 = UIAlertAction(title: title, style: style) { action in
                
                self.pinRecord()
            }
            alertController.addAction(action3)
        }
        
        
        if record.canEdit == 1 {
            let action4 = UIAlertAction(title: "Редактировать запись", style: .default) { action in
                
                var title = "Редактировать запись на своей стене"
                if record.postType == "postpone" {
                    title = "Редактировать отложенную запись"
                } else if record.postType == "suggest" {
                    title = "Редактировать предложенную запись"
                } else {
                    if record.ownerID > 0 {
                        if vkSingleton.shared.userID != "\(record.ownerID)" {
                            title = "Редактировать запись на чужой стене"
                        }
                    } else if record.ownerID < 0 {
                        title = "Редактировать запись на стене сообщества"
                    }
                }
                
                self.openNewRecordController(ownerID: "\(record.ownerID)", mode: .edit, title: title, record: record)
            }
            alertController.addAction(action4)
        }
        
        if record.postType == "post" && record.canDelete == 1 {
            if record.canComment == 1 {
                let action = UIAlertAction(title: "Закрыть комментирование", style: .destructive) { action in
                    
                    self.closeComments()
                }
                alertController.addAction(action)
            } else {
                let action = UIAlertAction(title: "Открыть комментирование", style: .default) { action in
                    
                    self.closeComments()
                }
                alertController.addAction(action)
            }
        }
        
        if record.postType == "postpone" {
            let action5 = UIAlertAction(title: "Опубликовать запись", style: .destructive) { action in
                
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
                
                alertView.addButton("Да, хочу опубликовать") {
                    
                    self.publishPostponedPost()
                }
                
                alertView.addButton("Нет, я передумал") {}
                
                alertView.showWarning("Подтверждение!", subTitle: "Вы действительно хотите опубликовать эту отложенную запись сейчас, в данный момент?")
            }
            alertController.addAction(action5)
        }
        
        
        if record.postType == "suggest" && vkSingleton.shared.adminGroupID.contains(abs(record.ownerID)) {
            let action5 = UIAlertAction(title: "Опубликовать запись", style: .default) { action in
                
                let title = "Опубликовать предложенную запись"
                
                self.openNewRecordController(ownerID: "\(record.ownerID)", mode: .edit, title: title, record: record)
            }
            alertController.addAction(action5)
        }
        
        
        if record.postType != "suggest" && record.canDelete == 1 {
            let action6 = UIAlertAction(title: "Удалить запись", style: .destructive) { action in
                
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
                    
                    self.deletePost()
                }
                
                alertView.addButton("Нет, я передумал") {}
                
                alertView.showWarning("Подтверждение!", subTitle: "Внимание! Данное действие необратимо.\nВы действительно хотите удалить эту запись с вашей стены?")
            }
            alertController.addAction(action6)
        }
        
        
        if record.postType == "suggest" && record.canDelete == 1 && "\(record.fromID)" == vkSingleton.shared.userID {
            let action6 = UIAlertAction(title: "Удалить запись", style: .destructive) { action in
                
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
                    
                    self.deletePost()
                }
                
                alertView.addButton("Нет, я передумал") {}
                
                alertView.showWarning("Подтверждение!", subTitle: "Внимание! Данное действие необратимо.\nВы действительно хотите удалить эту запись с вашей стены?")
            }
            alertController.addAction(action6)
        }
        
        
        if record.postType == "suggest" && record.canDelete == 1 && "\(record.fromID)" != vkSingleton.shared.userID {
            let action6 = UIAlertAction(title: "Отклонить запись", style: .destructive) { action in
                
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
                
                alertView.addButton("Да, хочу отклонить") {
                    
                    self.deletePost()
                }
                
                alertView.addButton("Нет, я передумал") {}
                
                alertView.showWarning("Подтверждение!", subTitle: "Внимание! Данное действие необратимо.\nВы действительно хотите отклонить данную запись?")
            }
            alertController.addAction(action6)
        }
        
        
        if record.postType != "postpone" && record.postType != "suggest" {
            let action7 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                
                if self.type == "post" {
                    record.reportMenu(delegate: self)
                } else if self.type == "photo" {
                    if let photo = self.photo {
                        photo.reportMenu(delegate: self)
                    }
                }
            }
            alertController.addAction(action7)
        }
        
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.barButton
            popoverController.permittedArrowDirections = [.up]
        }
        
        self.present(alertController, animated: true)
    }
    
    func createComment(text: String, stickerID: Int) {
        var url = ""
        var parameters: Parameters = [:]
        
        
        parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": self.uid,
            "message": text,
            "attachments": self.attachPanel.attachments,
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
                    self.attachPanel.replyID = 0
                    
                    if self.record.count > 0 {
                        self.record[0].commentsCount += 1
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
        var url = ""
        var parameters: Parameters = [:]
        
        
        parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": self.uid,
            "comment_id": "\(self.attachPanel.editID)",
            "message": text,
            "attachments": self.attachPanel.attachments,
            "v": vkSingleton.shared.version
        ]
        
        if self.type == "post" {
            url = "/method/wall.editComment"
            parameters["post_id"] = self.pid
        } else if self.type == "photo" {
            url = "/method/photos.editComment"
            parameters["photo_id"] = self.pid
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
                }
            } else {
                self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\(error.errorMsg)")
            }
        }
        
        OperationQueue().addOperation(request)
    }
    
    @objc func cancelEditMode(sender: UIBarButtonItem) {
        if type == "post" {
            self.title = "Запись"
        } else if type == "photo" {
            self.title = "Фотография"
        }
        
        self.barButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItem(sender:)))
        self.navigationItem.rightBarButtonItem = self.barButton
        
        self.setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
        self.commentView.textView.text = ""
        
        self.attachPanel.attachArray.removeAll(keepingCapacity: false)
        self.attachPanel.editID = 0
        self.attachPanel.replyID = 0
        
        self.tableView.reloadData()
    }
}
