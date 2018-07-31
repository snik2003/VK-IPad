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
import Popover

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
    var attachments = ""
    
    var navHeight: CGFloat = 64
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var heights: [IndexPath: CGFloat] = [:]
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    let product1 = [97, 98, 99, 100, 101, 102, 103, 105, 106, 107, 108, 109, 110,
                    111, 112, 113, 114, 115, 116, 118, 121, 125, 126, 127, 128]
    
    let product2 = [1, 2, 3, 4, 10, 13, 14, 15, 18, 21, 22, 25, 27, 28, 29, 30, 31,
                    35, 36, 37, 39, 40, 45, 46, 48]
    
    let product3 = [49, 50, 51, 54, 57, 59, 61, 63, 65, 66, 67, 68, 71, 72, 73, 74, 75,
                    76, 82, 83, 86, 87, 88, 89, 91]
    
    let product4 = [134, 140, 145, 136, 143, 151, 148, 144, 142, 137, 135, 133, 138,
                    156, 150, 153, 149, 147, 141, 159, 164, 161, 130, 132, 160]
    
    let product5 = [215, 232, 231, 211, 214, 218, 224, 225, 209, 226, 229, 223, 210,
                    220, 217, 227, 212, 216, 219, 228, 337, 338, 221, 213, 222]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
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
    
    func didSendComment(_ text: String!) {
        
        commentView.endEditing(true)
        //self.createVideoComment(text: text, attachments: attachments, stickerID: 0, replyID: 0, guid: "\(Date().timeIntervalSince1970)", controller: self)
    }
    
    func configureStickerView(sView: UIView, product: [Int], numProd: Int, width: CGFloat) {
        
        for subview in sView.subviews {
            if subview is UIButton {
                subview.removeFromSuperview()
            }
        }
        
        let bWidth = (width - 20) / 5
        for index in 0...product.count-1 {
            let sButton = UIButton()
            sButton.frame = CGRect(x: 10 + bWidth * CGFloat(index % 5) + 3, y: 10 + bWidth * CGFloat(index / 5) + 3, width: bWidth - 6, height: bWidth - 6)
            
            sButton.tag = product[index]
            let url = "https://vk.com/images/stickers/\(product[index])/256.png"
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    sButton.setImage(getCacheImage.outputImage, for: .normal)
                    sButton.add(for: .touchUpInside) {
                        //self.createVideoComment(text: "", attachments: "", stickerID: product[index], replyID: 0, guid: "\(Date().timeIntervalSince1970)", controller: self)
                        self.popover.dismiss()
                    }
                    sView.addSubview(sButton)
                }
            }
            OperationQueue().addOperation(getCacheImage)
        }
        
        
        for index in 1...5 {
            var startX = width / 2 - 50 * 2.5 - 10
            var url = "https://vk.com/images/stickers/105/256.png"
            
            if index == 2 {
                startX = width / 2 - 50 * 1.5 - 5
                url = "https://vk.com/images/stickers/3/256.png"
            }
            
            if index == 3 {
                startX = width / 2 - 25
                url = "https://vk.com/images/stickers/63/256.png"
            }
            
            if index == 4 {
                startX = width / 2 + 25 + 5
                url = "https://vk.com/images/stickers/145/256.png"
            }
            
            if index == 5 {
                startX = width / 2 + 50 * 1.5 + 10
                url = "https://vk.com/images/stickers/231/256.png"
            }
            
            let menuButton = UIButton()
            menuButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            menuButton.frame = CGRect(x: startX, y: width + 10, width: 50, height: 50)
            
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    let image = getCacheImage.outputImage
                    
                    menuButton.layer.cornerRadius = 10
                    menuButton.layer.borderColor = UIColor.gray.cgColor
                    menuButton.layer.borderWidth = 1
                    
                    if index == numProd {
                        menuButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 0.5)
                        menuButton.layer.cornerRadius = 10
                        menuButton.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
                        menuButton.layer.borderWidth = 1
                    }
                    
                    menuButton.setImage(image, for: .normal)
                    
                    if index == 1 {
                        menuButton.add(for: .touchUpInside) {
                            self.configureStickerView(sView: sView, product: self.product1, numProd: index, width: width)
                        }
                    }
                    if index == 2 {
                        menuButton.add(for: .touchUpInside) {
                            self.configureStickerView(sView: sView, product: self.product2, numProd: index, width: width)
                        }
                    }
                    if index == 3 {
                        menuButton.add(for: .touchUpInside) {
                            self.configureStickerView(sView: sView, product: self.product3, numProd: index, width: width)
                        }
                    }
                    if index == 4 {
                        menuButton.add(for: .touchUpInside) {
                            self.configureStickerView(sView: sView, product: self.product4, numProd: index, width: width)
                        }
                    }
                    if index == 5 {
                        menuButton.add(for: .touchUpInside) {
                            self.configureStickerView(sView: sView, product: self.product5, numProd: index, width: width)
                        }
                    }
                    sView.addSubview(menuButton)
                }
            }
            OperationQueue().addOperation(getCacheImage)
        }
    }
    
    @objc func tapStickerButton(sender: UIButton) {
        
        commentView.endEditing(true)
        
        let width: CGFloat = 320 //self.view.bounds.width - 20
        let height = width + 70
        let stickerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        configureStickerView(sView: stickerView, product: product1, numProd: 1, width: width)
        
        let point = CGPoint(x: self.commentView.stickerButton.frame.midX, y: self.view.frame.height - 10 - self.commentView.stickerButton.frame.height)
        self.popover = Popover(options: self.popoverOptions)
        self.popover.show(stickerView, point: point, inView: self.view)
    }
    
    @objc func tapAccessoryButton(sender: UIButton) {
        
        //self.openNewCommentController(ownerID: ownerID, message: commentView.textView.text!, type: "new_video_comment", title: "Новый комментарий", replyID: 0, replyName: "", comment: nil, controller: self)
    }
    
    func configureTableView() {
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        commentView = DCCommentView.init(scrollView: self.tableView, frame: self.view.bounds)
        commentView.delegate = self
        commentView.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        
        commentView.sendImage = UIImage(named: "send")
        commentView.stickerImage = UIImage(named: "sticker")
        commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
        
        if vkSingleton.shared.commentFromGroup > 0 && vkSingleton.shared.commentFromGroup == abs(Int(self.ownerID)!) {
            //setCommentFromGroupID(id: vkSingleton.shared.commentFromGroup, controller: self)
        } else {
            //setCommentFromGroupID(id: 0, controller: self)
        }
        
        
        commentView.accessoryImage = UIImage(named: "attachment")
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        
        tableView.register(VideoCell.self, forCellReuseIdentifier: "videoCell")
        tableView.register(CommentCell.self, forCellReuseIdentifier: "commentCell")
    }
    
    @objc func tapFromGroupButton(sender: UIButton) {
        self.commentView.endEditing(true)
        //self.actionFromGroupButton(fromView: commentView.fromGroupButton)
    }
    
    func getVideo() {
        
         var code = "var a = API.video.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(self.ownerID)\",\"videos\":\"\(ownerID)_\(vid)_\(accessKey)\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, photo_100\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var b = API.likes.getList({\"type\":\"video\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(ownerID)\",\"item_id\":\"\(vid)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, photo_100, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\": \"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var c = API.video.getComments({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(ownerID)\",\"video_id\":\"\(vid)\",\"need_likes\":\"1\",\"offset\":\"\(offset)\",\"count\":\"\(count)\",\"sort\":\"desc\",\"preview_length\":\"0\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
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
            "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc",
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
                
                cell.selectionStyle = .none
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    @objc func showReplyComment(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let buttonPosition: CGPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                
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
                    "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex",
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
            
            if video.canAdd == 1 {
                let action1 = UIAlertAction(title: "Добавить в \"Мои видеозаписи\"", style: .default) { action in
                    
                    let url = "/method/video.add"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "target_id": vkSingleton.shared.userID,
                        "owner_id": "\(video.ownerID)",
                        "video_id": "\(video.id)",
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
                            self.showSuccessMessage(title: "Мои видеозаписи", msg: "\nВидеозапись \"\(video.title)\" успешно добавлена.\n")
                        } else {
                            var title = "Ошибка #\(error.errorCode)"
                            var msg = "\n\(error.errorMsg)\n"
                            if error.errorCode == 800 {
                                title = "Мои видеозаписи"
                                msg = "\nЭта видеозапись уже добавлена.\n"
                            }
                            if error.errorCode == 204 {
                                title = "Мои видеозаписи"
                                msg = "\nОшибка. Нет доступа.\n"
                            }
                            self.showErrorMessage(title: title, msg: msg)
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action1)
            }
            
            let action4 = UIAlertAction(title: "Удалить из \"Мои видеозаписи\"", style: .destructive) { action in
                
                let url = "/method/video.delete"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "target_id": vkSingleton.shared.userID,
                    "owner_id": "\(video.ownerID)",
                    "video_id": "\(video.id)",
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
                        self.showSuccessMessage(title: "Мои видеозаписи", msg: "\nВидеозапись \"\(video.title)\" успешно удалена.\n")
                    } else {
                        let title = "Ошибка #\(error.errorCode)"
                        let msg = "\n\(error.errorMsg)\n"
                        self.showErrorMessage(title: title, msg: msg)
                    }
                }
                
                OperationQueue().addOperation(request)
            }
            alertController.addAction(action4)
            
            let action5 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                
                let link = "https://vk.com/video\(self.ownerID)_\(self.vid)"
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.showInfoMessage(title: "Ссылка на видеозапись:" , msg: "\(string)")
                }
            }
            alertController.addAction(action5)
            
            let action6 = UIAlertAction(title: "Добавить ссылку в \"Избранное\"", style: .default) { action in
                
                //let link = "https://vk.com/video\(self.ownerID)_\(self.vid)"
                //self.addLinkToFave(link: link, text: "Видеозапись")
            }
            alertController.addAction(action6)
            
            let action2 = UIAlertAction(title: "Пожаловаться", style: .destructive) { action in
                
                //self.reportOnObject(ownerID: self.ownerID, itemID: self.vid, type: "video")
            }
            alertController.addAction(action2)
            
            
            present(alertController, animated: true)
        }
    }
}
