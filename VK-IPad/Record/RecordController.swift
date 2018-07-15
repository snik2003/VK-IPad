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
    var attachments = ""
    
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
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        OperationQueue.main.addOperation {
            self.configureTableView()
            
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        getRecord()
        StoreReviewHelper.checkAndAskForReview()
    }

    func configureTableView() {
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        commentView = DCCommentView.init(scrollView: self.tableView, frame: self.tableView.bounds)
        commentView.delegate = self
        commentView.tintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        
        commentView.sendImage = UIImage(named: "send")
        commentView.stickerImage = UIImage(named: "sticker")
        commentView.stickerButton.addTarget(self, action: #selector(self.tapStickerButton(sender:)), for: .touchUpInside)
        
        commentView.accessoryImage = UIImage(named: "attachment")
        commentView.accessoryButton.addTarget(self, action: #selector(self.tapAccessoryButton(sender:)), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(RecordCell.self, forCellReuseIdentifier: "recordCell")
        tableView.register(CommentCell.self, forCellReuseIdentifier: "commentCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func tapAccessoryButton(sender: UIButton) {
        
        
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
    
    func didSendComment(_ text: String!) {
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if record.count > 0 {
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
        if indexPath.section == 0 {
            if let height = heights[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! RecordCell
                
                cell.delegate = self
                cell.record = record[0]
                cell.cellWidth = self.tableView.frame.width
                cell.showLikesPanel = true
                
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        return cell
    }
    
    func getRecord() {
        
        heights.removeAll(keepingCapacity: false)
        
        if type == "post" {
            
            var code = "var a = API.wall.getById({\"posts\":\"\(uid)_\(pid)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"extended\":\"1\",\"copy_history_depth\":\"3\",\"fields\":\"id,first_name,first_name_gen,last_name,last_name_gen,photo_max,photo_100\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var b = API.likes.getList({\"type\":\"post\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(uid)\",\"item_id\":\"\(pid)\",\"filter\":\"likes\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, photo_100, deactivated, first_name_dat, friend_status\",\"count\":\"1000\",\"skip_own\":\"0\",\"v\": \"\(vkSingleton.shared.version)\"}); \n"
            
            code = "\(code) var c = API.wall.getComments({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(uid)\",\"post_id\":\"\(pid)\",\"need_likes\":\"1\",\"offset\":\"\(offset)\",\"count\":\"\(count)\",\"sort\":\"desc\",\"preview_length\":\"0\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
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
            
            code = "\(code) var c = API.photos.getComments({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"owner_id\":\"\(uid)\",\"photo_id\":\"\(pid)\",\"need_likes\":\"1\",\"offset\":\"\(offset)\",\"count\":\"\(count)\",\"sort\":\"desc\",\"preview_length\":\"0\",\"extended\":\"1\",\"fields\":\"id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
            
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
                "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex",
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
                "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex",
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
                self.tableView.reloadData()
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 1, section: 1), at: .top, animated: true)
                }
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    @objc func showReplyComment(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let buttonPosition: CGPoint = sender.location(in: self.tableView)
            
            if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                
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
                    "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex",
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
                        "fields": "id, first_name, last_name, photo_max_orig, photo_100, first_name_dat, first_name_acc, sex",
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
}
