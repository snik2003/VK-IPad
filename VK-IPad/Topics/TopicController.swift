//
//  TopicController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 31.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
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
    var optButton: UIBarButtonItem!
    
    var delegate: UIViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTableView()
        getTopicComments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func createTableView() {
        tableView = UITableView()
        
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
        
        tableView.register(TopicCell.self, forCellReuseIdentifier: "topicCell")
        tableView.register(CommentCell.self, forCellReuseIdentifier: "commentCell")
        
        tableView.separatorStyle = .none
    }
    
    @objc func tapStickerButton(sender: UIButton) {
        
    }
    
    @objc func tapAccessoryButton(sender: UIButton) {
        
    }
    
    func didSendComment(_ text: String!) {
        
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        
    }
    
    func getTopicComments() {
        let opq = OperationQueue()
        
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
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
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
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
            return comments.count + 1
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
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
                cell.topic = topics[indexPath.section]
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
                cell.indexPath = indexPath
                cell.cell = cell
                cell.tableView = self.tableView
                cell.comment = comment
                cell.users = users
                cell.groups = groups
                
                cell.cellWidth = self.width
                
                cell.configureCell()
                
                cell.selectionStyle = .none
                
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
    }
}
