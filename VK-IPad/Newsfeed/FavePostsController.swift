//
//  FavePostsController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 23.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class FavePostsController: UIViewController, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate {
    
    var heights: [IndexPath: CGFloat] = [:]
    
    var userID = vkSingleton.shared.userID
    var source = "post"
    
    var selectedMenu = 0
    var menuButton = UIButton()
    let itemsMenu = ["Избранные посты", "Избранные фотографии", "Избранные видеозаписи", "Избранные пользователи", "Избранные сообщества", "Избранные ссылки", "Черный список"]
    
    var records = [Record]()
    var users = [UserProfile]()
    var groups = [GroupProfile]()
    
    var photos = [Photo]()
    var videos = [Video]()
    var links = [FaveLinks]()
    
    var offset = 0
    let count = 30
    var totalCount = 0
    var isRefresh = false
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView()
        createTableView()
        refresh()
    }
    
    func createTableView() {
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(RecordCell.self, forCellReuseIdentifier: "recordCell")
        tableView.register(PhotosListCell.self, forCellReuseIdentifier: "photoCell")
        tableView.register(VideoListCell.self, forCellReuseIdentifier: "videoCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "usersCell")
        tableView.register(FavePostsCell.self, forCellReuseIdentifier: "faveCell")
        
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
    }
    
    func refresh() {
        var url: String = ""
        var parameters: Parameters = [:]
        isRefresh = true
        
        OperationQueue.main.addOperation {
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        if offset == 0 {
            records.removeAll(keepingCapacity: false)
            users.removeAll(keepingCapacity: false)
            groups.removeAll(keepingCapacity: false)
            photos.removeAll(keepingCapacity: false)
            videos.removeAll(keepingCapacity: false)
            tableView.separatorStyle = .none
            tableView.reloadData()
            
            heights.removeAll(keepingCapacity: false)
        }
        
        if source == "post" {
            url = "/method/fave.getPosts"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "\(offset)",
                "count": "\(count)",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_max, photo_100",
                "v": vkSingleton.shared.version
            ]
        } else if source == "photo" {
            url = "/method/fave.getPhotos"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "\(offset)",
                "count": "\(count)",
                "v": vkSingleton.shared.version
            ]
        } else if source == "video" {
            url = "/method/fave.getVideos"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "\(offset)",
                "count": "\(count)",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_max, photo_100",
                "v": vkSingleton.shared.version
            ]
        } else if source == "links" || source == "groups" {
            url = "/method/fave.getLinks"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "\(offset)",
                "count": "\(count)",
                "v": vkSingleton.shared.version
            ]
        } else if source == "users" {
            url = "/method/fave.getUsers"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "count": "\(count)",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_100, last_seen, online, online_mobile, deactivated",
                "v": vkSingleton.shared.version
            ]
        } else if source == "banned" {
            url = "/method/account.getBanned"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "0",
                "count": "200",
                "extended": "1",
                "fields": "id, first_name, last_name, photo_100, last_seen, online, online_mobile, deactivated",
                "v": vkSingleton.shared.version
            ]
        }
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            if self.source == "post" {
                let records = json["response"]["items"].compactMap { Record(json: $0.1) }
                let users = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
                let groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
                
                if self.offset == 0 {
                    self.records = records
                    self.users = users
                    self.groups = groups
                } else {
                    for record in records {
                        self.records.append(record)
                    }
                    for user in users {
                        self.users.append(user)
                    }
                    for group in groups {
                        self.groups.append(group)
                    }
                }
            } else if self.source == "photo" {
                let photos = json["response"]["items"].compactMap { Photo(json: $0.1) }
                
                if self.offset == 0 {
                    self.photos = photos
                } else {
                    for photo in photos {
                        self.photos.append(photo)
                    }
                }
            } else if self.source == "video" {
                let videos = json["response"]["items"].compactMap { Video(json: $0.1) }
                let users = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
                let groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
                
                if self.offset == 0 {
                    self.videos = videos
                    self.users = users
                    self.groups = groups
                } else {
                    for video in videos {
                        self.videos.append(video)
                    }
                    for user in users {
                        self.users.append(user)
                    }
                    for group in groups {
                        self.groups.append(group)
                    }
                }
            } else if self.source == "users" || self.source == "banned" {
                let users = json["response"]["items"].compactMap { UserProfile(json: $0.1) }
                
                if self.offset == 0 {
                    self.users = users
                } else {
                    for user in users {
                        self.users.append(user)
                    }
                }
                
                self.tableView.separatorStyle = .singleLine
            } else {
                let links = json["response"]["items"].compactMap { FaveLinks(json: $0.1) }
                
                if self.offset == 0 {
                    self.links.removeAll(keepingCapacity: false)
                }
                
                for link in links {
                    if self.source == "groups" {
                        let arr = link.id.components(separatedBy: "_")
                        if arr.count > 2, arr[0] == "2" {
                            self.links.append(link)
                        }
                    } else if self.source == "links" {
                        if link.id.prefix(2) != "2_" {
                            self.links.append(link)
                        }
                    }
                }
                
                self.tableView.separatorStyle = .singleLine
            }
            
            self.totalCount = json["response"]["count"].intValue
            
            OperationQueue.main.addOperation {
                self.offset += self.count
                
                self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
                
                self.tableView.reloadData()
                ViewControllerUtils().hideActivityIndicator()
            }
            
            self.setOfflineStatus(dependence: nil)
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        switch source {
        case "post":
            return records.count
        case "photo":
            return 1
        case "video":
            return videos.count
        case "users":
            return 1
        case "groups":
            return 1
        case "links":
            return 1
        case "banned":
            return 1
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch source {
        case "post":
            return 1
        case "photo":
            return photos.count / 3 + photos.count % 3
        case "video":
            return 1
        case "users":
            return users.count
        case "groups":
            return links.count
        case "links":
            return links.count
        case "banned":
            return users.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if source == "post" {
            if let height = heights[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! RecordCell
                
                cell.delegate = self
                cell.record = records[indexPath.section]
                cell.cellWidth = self.tableView.frame.width
                cell.showLikesPanel = true
                
                let height = cell.getRowHeight()
                heights[indexPath] = height
                
                return height
            }
        } else if source == "photo" {
            return (self.view.bounds.width * 0.333) * CGFloat(240) / CGFloat(320)
        } else if source == "video" {
            return (self.view.bounds.width * 0.5) * CGFloat(240) / CGFloat(320)
        } else if source == "users" || source == "banned" || source == "groups" || source == "links" {
            return 50
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if source == "post" {
            if let height = heights[indexPath] {
                return height
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! RecordCell
                
                cell.delegate = self
                cell.record = records[indexPath.section]
                cell.cellWidth = self.tableView.frame.width
                cell.showLikesPanel = true
                
                let height = cell.getRowHeight()
                heights[indexPath] = height
                
                return height
            }
        } else if source == "photo" {
            return (self.view.bounds.width * 0.333) * CGFloat(240) / CGFloat(320)
        } else if source == "video" {
            return (self.view.bounds.width * 0.5) * CGFloat(240) / CGFloat(320)
        } else if source == "users" || source == "banned" || source == "groups" || source == "links" {
            return 50
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if source == "post" || source == "users" || source == "banned" || source == "links" || source == "groups" {
            if section == 0 {
                return 10
            }
        }
        
        if source == "video" {
            if section == 0 {
                return 15
            }
            return 25
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if source == "post" || source == "users" || source == "banned" || source == "links" || source == "groups" {
            return 10
        }
        
        if source == "video" {
            if section == tableView.numberOfSections - 1 {
                return 15
            }
            return 0
        }
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        viewHeader.backgroundColor = UIColor.white
        
        if source == "video" {
            let separator = UIView()
            if section == 0 {
                separator.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 5)
            } else {
                separator.frame = CGRect(x: 0, y: 10, width: tableView.bounds.width, height: 5)
            }
            separator.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.8)
            viewHeader.addSubview(separator)
        }
        
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = UIColor.white
        
        if source == "post" {
            viewFooter.backgroundColor = vkSingleton.shared.backColor
        }
        
        if source == "video" {
            let separator = UIView()
            separator.frame = CGRect(x: 0, y: 10, width: tableView.bounds.width, height: 5)
            separator.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.8)
            viewFooter.addSubview(separator)
        }
        
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch source {
        case "post":
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordCell
            
            cell.delegate = self
            cell.indexPath = indexPath
            cell.cell = cell
            cell.tableView = self.tableView
            cell.showLikesPanel = true
            
            cell.record = records[indexPath.section]
            cell.users = users
            cell.groups = groups
            
            cell.cellWidth = self.tableView.frame.width
            
            cell.configureCell()
            
            return cell
        case "photo":
            let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotosListCell
            
            cell.delegate = self
            cell.photos = photos
            
            cell.indexPath = indexPath
            cell.cellWidth = self.view.bounds.width
            
            cell.configureCell()
            cell.selectionStyle = .none
            
            return cell
        case "video":
            let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoListCell
            
            cell.delegate = self
            
            cell.video = videos[indexPath.section]
            cell.indexPath = indexPath
            cell.cell = cell
            cell.tableView = tableView
            cell.cellWidth = self.view.bounds.width
            
            cell.configureCell()
            
            cell.selectionStyle = .none
            
            return cell
        case "users","banned":
            let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath)
            
            let user = users[indexPath.row]
            
            cell.imageView?.image = UIImage(named: "nophoto")
            cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
            cell.textLabel?.font = UIFont(name: "Verdana", size: 15)
            
            let getCacheImage = GetCacheImage(url: user.photo100, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                cell.imageView?.layer.cornerRadius = cell.bounds.height/2
                cell.imageView?.clipsToBounds = true
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            
            return cell
        case "groups":
            let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath)
            
            let group = links[indexPath.row]
            
            cell.imageView?.image = UIImage(named: "nophoto")
            cell.textLabel?.text = "\(group.title)"
            cell.textLabel?.font = UIFont(name: "Verdana", size: 15)
            
            let getCacheImage = GetCacheImage(url: group.photoURL, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                cell.imageView?.layer.cornerRadius = cell.bounds.height/2
                cell.imageView?.clipsToBounds = true
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            
            return cell
        case "links":
            let cell = tableView.dequeueReusableCell(withIdentifier: "faveCell", for: indexPath) as! FavePostsCell
            
            cell.link = links[indexPath.row]
            cell.cellWidth = self.view.frame.width
            
            cell.configureCell()
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            cell.selectionStyle = .none
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if source == "users" || source == "banned" {
            let user = users[indexPath.row]
            
            if let id = Int(user.uid) {
                self.openProfileController(id: id, name: "\(user.firstName) \(user.lastName)")
            }
        }
        
        if source == "groups" || source == "links" {
            let link = links[indexPath.row]
            
            self.openBrowserController(url: link.url)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if source == "links" {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Удалить") { (rowAction, indexPath) in
            
            let link = self.links[indexPath.row]
            link.removeFromFave(delegate: self)
        }
        deleteAction.backgroundColor = .red
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if source == "post" || source == "video" {
            if indexPath.section == tableView.numberOfSections - 1 && offset < totalCount {
                isRefresh = false
            }
        } else if source == "photo" {
            if indexPath.row == tableView.numberOfRows(inSection: 0)-1 && offset < totalCount {
                isRefresh = false
            }
        } else {
            if indexPath.row == tableView.numberOfRows(inSection: 0)-1 && indexPath.row == offset - 1 {
                isRefresh = false
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            refresh()
        }
    }
    
    func setTitleView() {
        menuButton.frame = CGRect(x: 0, y: 0, width: 300, height: 40)
        menuButton.backgroundColor = UIColor.clear
        
        menuButton.setTitle(itemsMenu[0], for: .normal)
        menuButton.setTitleColor(UIColor.white, for: .normal)
        menuButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        menuButton.setImage(UIImage(named: "arrow-down"), for: .normal)
        menuButton.imageView?.tintColor = UIColor.white
        menuButton.imageView?.contentMode = .scaleAspectFit
        menuButton.imageView?.clipsToBounds = true
        
        menuButton.addTarget(self, action: #selector(self.clickTitle(sender:)), for: .touchUpInside)
        self.navigationItem.titleView = menuButton
    }
    
    @objc func clickTitle(sender: UIButton) {
        menuButton.setImage(UIImage(named: "arrow-up"), for: .normal)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
            self.menuButton.setImage(UIImage(named: "arrow-down"), for: .normal)
        }
        alertController.addAction(cancelAction)
        
        for index in 0...itemsMenu.count-1 {
            if menuButton.titleLabel?.text == itemsMenu[index] {
                let action = UIAlertAction(title: itemsMenu[index], style: .destructive) { action in
                    self.menuButton.setImage(UIImage(named: "arrow-down"), for: .normal)
                }
                alertController.addAction(action)
            } else {
                let action = UIAlertAction(title: itemsMenu[index], style: .default) { action in
                    
                    switch index {
                    case 0:
                        self.source = "post"
                        break
                    case 1:
                        self.source = "photo"
                        break
                    case 2:
                        self.source = "video"
                        break
                    case 3:
                        self.source = "users"
                        break
                    case 4:
                        self.source = "groups"
                        break
                    case 5:
                        self.source = "links"
                        break
                    case 6:
                        self.source = "banned"
                        break
                    default:
                        break
                    }
                    
                    self.offset = 0
                    self.refresh()
                    self.heights.removeAll(keepingCapacity: false)
                    self.menuButton.setTitle(self.itemsMenu[index], for: .normal)
                    self.menuButton.setImage(UIImage(named: "arrow-down"), for: .normal)
                }
                alertController.addAction(action)
            }
        }
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.minY + 60, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.up]
        }
        
        self.present(alertController, animated: true)
    }
}
