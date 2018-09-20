//
//  NewsfeedController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 20.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

import UIKit
import Alamofire
import SwiftyJSON

class NewsfeedController: UITableViewController {
    
    var heights: [IndexPath: CGFloat] = [:]
    
    var selectedMenu = 0
    var menuButton = UIButton()
    let itemsMenu = ["Рекомендации", "Новости", "Друзья", "Сообщества", "Фотографии"]
    
    var userID = vkSingleton.shared.userID
    var news: [Record] = []
    var profiles: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    var hashTag = ""
    
    var filters = "post"
    var sourceIDs = "recommend"
    var startFrom = ""
    var offset = 0
    let count = 100
    var totalCount = 0
    
    var isRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView()
        
        self.refreshControl?.addTarget(self, action: #selector(self.refreshButtonClick), for: UIControlEvents.valueChanged)
        refreshControl?.tintColor = UIColor.gray
        tableView.addSubview(refreshControl!)
        
        refresh()
    }
    
    @objc func refreshButtonClick()
    {
        startFrom = ""
        offset = 0
        refresh()
    }
    
    func refresh() {
        var url: String
        var parameters: Parameters
        
        isRefresh = true
        
        heights.removeAll(keepingCapacity: false)
        
        OperationQueue.main.addOperation {
            self.refreshControl?.beginRefreshing()
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator2(controller: self)
        }
        
        if startFrom == "" && offset == 0 {
            news.removeAll(keepingCapacity: false)
            profiles.removeAll(keepingCapacity: false)
            groups.removeAll(keepingCapacity: false)
            tableView.reloadData()
        }
        
        if hashTag != "" {
            url = "/method/newsfeed.search"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "q": hashTag,
                "extended": "1",
                "count": "200",
                "fields": "id,first_name,last_name,photo_100,photo_200,first_name_gen",
                "v": vkSingleton.shared.version
            ]
        } else if sourceIDs == "recommend" {
            url = "/method/newsfeed.getRecommended"
            
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "filters": filters,
                "max_photos": "10",
                "star_from": "\(startFrom)",
                "count": "\(count)",
                "fields": "id,first_name,last_name,photo_100,photo_200,first_name_gen",
                "v": vkSingleton.shared.version
            ]
        } else {
            url = "/method/newsfeed.get"
            
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "filters": filters,
                "source_ids": sourceIDs,
                "return_banned": "0",
                "start_time": Date().timeIntervalSince1970 - 15552000,
                "end_time": Date().timeIntervalSince1970,
                "start_from": "\(startFrom)",
                "count": "\(count)",
                "fields": "id,first_name,last_name,photo_100,photo_200,first_name_gen",
                "v": vkSingleton.shared.version
            ]
        }
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            self.setOfflineStatus(dependence: nil)
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            var news: [Record] = []
            if self.filters != "wall_photo" {
                news = json["response"]["items"].compactMap { Record(json: $0.1) }
            } else {
                for index in 0...self.count-1 {
                    let record = Record(json: JSON.null)
                    record.id = json["response"]["items"][index]["post_id"].intValue
                    if record.id != 0 {
                        record.ownerID = json["response"]["items"][index]["source_id"].intValue
                        record.fromID = json["response"]["items"][index]["source_id"].intValue
                        record.date = json["response"]["items"][index]["date"].intValue
                        
                        let count = json["response"]["items"][index]["photos"]["count"].intValue
                        for index2 in 0...count-1 {
                            let json2 = json["response"]["items"][index]["photos"]["items"][index2]
                            
                            let attach = Attachment(json: JSON.null)
                            attach.type = "photo"
                            
                            let photo = Photo(json: JSON.null)
                            photo.id = json2["id"].intValue
                            photo.width = json2["width"].intValue
                            photo.height = json2["height"].intValue
                            if photo.id > 0 && photo.width > 0 && photo.height > 0 {
                                photo.albumID = json2["album_id"].intValue
                                photo.ownerID = json2["owner_id"].intValue
                                photo.userID = json2["user_id"].intValue
                                photo.text = json2["text"].stringValue
                                photo.date = json2["date"].intValue
                                photo.photo75 = json2["photo_75"].stringValue
                                photo.photo130 = json2["photo_130"].stringValue
                                photo.photo604 = json2["photo_604"].stringValue
                                photo.photo807 = json2["photo_807"].stringValue
                                photo.photo1280 = json2["photo_1280"].stringValue
                                photo.photo2560 = json2["photo_2560"].stringValue
                                photo.accessKey = json2["access_key"].stringValue
                                attach.photo.append(photo)
                            }
                            record.attachments.append(attach)
                        }
                        
                        news.append(record)
                    }
                }
            }
            
            
            let profiles = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
            let groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
            
            let nextFrom = json["response"]["next_from"].stringValue
            self.totalCount = json["response"]["count"].intValue
            
            OperationQueue.main.addOperation {
                if self.startFrom == "" && self.offset == 0 {
                    self.news = news
                    self.profiles = profiles
                    self.groups = groups
                } else {
                    for new in news {
                        self.news.append(new)
                    }
                    for profile in profiles {
                        self.profiles.append(profile)
                    }
                    for group in groups {
                        self.groups.append(group)
                    }
                }
                
                self.startFrom = nextFrom
                self.offset += self.count
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return news.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heights[indexPath] {
            return height
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! RecordCell
            
            cell.delegate = self
            cell.record = news[indexPath.section]
            cell.cellWidth = self.tableView.frame.width
            cell.showLikesPanel = true
            if self.filters == "wall_photo" {
                cell.showLikesPanel = false
            }
            
            let height = cell.getRowHeight()
            heights[indexPath] = height
            
            return height
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let height = heights[indexPath] {
            return height
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell") as! RecordCell
            
            cell.delegate = self
            cell.record = news[indexPath.section]
            cell.cellWidth = self.tableView.frame.width
            cell.showLikesPanel = true
            if self.filters == "wall_photo" {
                cell.showLikesPanel = false
            }
            
            let height = cell.getRowHeight()
            heights[indexPath] = height
            
            return height
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = vkSingleton.shared.backColor
        
        return viewFooter
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordCell
        
        cell.delegate = self
        cell.indexPath = indexPath
        cell.cell = cell
        cell.tableView = self.tableView
        cell.showLikesPanel = true
        if self.filters == "wall_photo" {
            cell.showLikesPanel = false
        }
        
        cell.record = news[indexPath.section]
        cell.users = profiles
        cell.groups = groups
        
        cell.cellWidth = self.tableView.frame.width
        
        cell.configureCell()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections - 1 && indexPath.section == offset - 1 {
            isRefresh = false
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            refresh()
        }
    }
    
    func setTitleView() {
        if hashTag == "" {
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
        } else {
            self.title = hashTag
        }
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
                        self.filters = "post"
                        self.sourceIDs = "recommend"
                        break
                    case 1:
                        self.filters = "post"
                        self.sourceIDs = ""
                        break
                    case 2:
                        self.filters = "post"
                        self.sourceIDs = "friends,following"
                        break
                    case 3:
                        self.filters = "post"
                        self.sourceIDs = "groups,pages"
                        break
                    case 4:
                        self.filters = "wall_photo"
                        self.sourceIDs = "friends,following"
                        break
                    default:
                        break
                    }
                    
                    self.startFrom = ""
                    self.offset = 0
                    self.refresh()
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
