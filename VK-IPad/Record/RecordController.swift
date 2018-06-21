//
//  RecordController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 20.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class RecordController: UITableViewController {

    var delegate: UIViewController!
    var heights: [IndexPath: CGFloat] = [:]
    
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
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        OperationQueue.main.addOperation {
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        getRecord()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if record.count > 0 {
                return 5
            }
        }
        return 0.001
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = vkSingleton.shared.backColor
        
        return viewHeader
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = vkSingleton.shared.backColor
        
        return viewFooter
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
                    cell.countButton.removeTarget(nil, action: nil, for: .allEvents)
                    cell.countButton.add(for: .touchUpInside) {
                        
                    }
                } else {
                    cell.removeAllSubviews()
                }
               
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
            
                let comment = comments[comments.count - indexPath.row]
                
                cell.delegate = self
                cell.comment = comment
                cell.users = commentsProfiles
                cell.groups = commentsGroups
                
                cell.cellWidth = self.tableView.frame.width
                
                cell.configureCell()
                
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
                    
                    /*if self.record.count > 0 {
                        if self.record[0].canComment == 0 {
                            self.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 49)
                            self.view.addSubview(self.tableView)
                            self.commentView.removeFromSuperview()
                        } else {
                            self.view.addSubview(self.commentView)
                        }
                    }*/
                    
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
                //print(json)
                
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
                    
                    /*if self.record.count > 0 {
                     if self.record[0].canComment == 0 {
                     self.tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 49)
                     self.view.addSubview(self.tableView)
                     self.commentView.removeFromSuperview()
                     } else {
                     self.view.addSubview(self.commentView)
                     }
                     }*/
                    
                    self.offset += self.count
                    self.tableView.reloadData()
                    self.tableView.separatorStyle = .singleLine
                    ViewControllerUtils().hideActivityIndicator()
                }
            }
            queue.addOperation(getServerDataOperation)
        }
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
    }
}
