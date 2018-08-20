//
//  GroupProfileViewController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 19.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class GroupProfileViewController: UITableViewController {

    var groupProfile: [GroupProfile] = []
    
    var heights: [IndexPath: CGFloat] = [:]
    var recordsCount: Int = 0
    
    var groupID = 0
    
    var offset = 0
    let count = 40
    var filterRecords = "all"
    
    var wall: [Record] = []
    var wallProfiles: [UserProfile] = []
    var wallGroups: [GroupProfile] = []
    
    var suggestedWall: [Record] = []
    
    var postponedWall: [Record] = []
    var postponedWallProfiles: [UserProfile] = []
    var postponedWallGroups: [GroupProfile] = []
    
    var isRefresh = false
    
    var profileView: GroupProfileView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.refreshControl?.addTarget(self, action: #selector(self.pullToRefresh), for: UIControlEvents.valueChanged)
            self.refreshControl?.tintColor = UIColor.gray
            self.tableView.addSubview(self.refreshControl!)
            
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return wall.count
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
            cell.record = wall[indexPath.section]
            cell.cellWidth = self.tableView.frame.width
            cell.showLikesPanel = true
            if self.filterRecords == "postponed" || self.filterRecords == "suggests" {
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
            cell.record = wall[indexPath.section]
            cell.cellWidth = self.tableView.frame.width
            cell.showLikesPanel = true
            
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
        
        cell.record = wall[indexPath.section]
        cell.users = wallProfiles
        cell.groups = wallGroups
        
        cell.cellWidth = self.tableView.frame.width
        
        cell.configureCell()
        
        return cell
    }
    
    @objc func pullToRefresh() {
        offset = 0
        refresh()
    }
    
    func refresh() {
        
        isRefresh = true
        
        heights.removeAll(keepingCapacity: false)
        
        // получаем объект с сервера ВК
        let url1 = "/method/groups.getById"
        let parameters1 = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed,can_message,contacts,verified",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url1, parameters: parameters1)
        OperationQueue().addOperation(getServerDataOperation)
        
        // парсим объект
        let parseGroupProfile = ParseGroupProfile()
        parseGroupProfile.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseGroupProfile)
        
        let url2 = "/method/wall.get"
        let parameters2 = [
            "owner_id": "-\(groupID)",
            "domain": "",
            "offset": "\(offset)",
            "access_token": vkSingleton.shared.accessToken,
            "count": "\(count)",
            "filter": "all",
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
        OperationQueue().addOperation(getServerDataOperation2)
        
        let parseGroupWall = ParseWall()
        parseGroupWall.addDependency(getServerDataOperation2)
        OperationQueue().addOperation(parseGroupWall)
        
        
        let url3 = "/method/wall.get"
        let parameters3 = [
            "owner_id": "-\(groupID)",
            "domain": "",
            "access_token": vkSingleton.shared.accessToken,
            "count": "100",
            "filter": "postponed",
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation3 = GetServerDataOperation(url: url3, parameters: parameters3)
        OperationQueue().addOperation(getServerDataOperation3)
        
        let parsePostponedGroupWall = ParseWall()
        parsePostponedGroupWall.addDependency(getServerDataOperation3)
        OperationQueue().addOperation(parsePostponedGroupWall)
        
        
        let url4 = "/method/wall.get"
        let parameters4 = [
            "owner_id": "-\(groupID)",
            "domain": "",
            "access_token": vkSingleton.shared.accessToken,
            "count": "100",
            "filter": "suggests",
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation4 = GetServerDataOperation(url: url4, parameters: parameters4)
        OperationQueue().addOperation(getServerDataOperation4)
        
        let parseSuggestedGroupWall = ParseWall()
        parseSuggestedGroupWall.addDependency(getServerDataOperation4)
        OperationQueue().addOperation(parseSuggestedGroupWall)
        
        
        let reloadTableController = ReloadGroupProfileController(controller: self)
        reloadTableController.addDependency(parseGroupWall)
        reloadTableController.addDependency(parseGroupProfile)
        reloadTableController.addDependency(parsePostponedGroupWall)
        reloadTableController.addDependency(parseSuggestedGroupWall)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections - 1 && indexPath.section == offset - 1 {
            isRefresh = false
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            refreshWall(filter: filterRecords)
        }
    }
    
    func setProfileView() {
        if groupProfile.count > 0 {
            profileView = GroupProfileView()
            profileView.backgroundColor = vkSingleton.shared.backColor
            
            profileView.delegate = self
            profileView.profile = groupProfile[0]
            
            let height = profileView.configureView()
                
            self.profileView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: height)
            self.tableView.tableHeaderView = self.profileView
        }
    }
    
    func refreshWall(filter: String) {
        isRefresh = true
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        heights.removeAll(keepingCapacity: false)
        filterRecords = filter
        recordsCount = 0
        
        let url = "/method/wall.get"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": "-\(groupID)",
            "offset": "\(offset)",
            "count": "\(count)",
            "filter": filterRecords,
            "extended": "1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            let items = json["response"]["items"].compactMap { Record(json: $0.1) }
            let profiles = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
            let groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
            
            self.recordsCount = json["response"]["count"].intValue
            
            if self.offset == 0 {
                self.wall = items
                self.wallProfiles = profiles
                self.wallGroups = groups
            } else {
                for item in items {
                    self.wall.append(item)
                }
                for profile in profiles {
                    self.wallProfiles.append(profile)
                }
                for group in groups {
                    self.wallGroups.append(group)
                }
            }
            
            OperationQueue.main.addOperation {
                self.profileView.updateOwnerButtons()
                self.profileView.recordsCountLabel.text = "Всего записей: \(self.recordsCount)"
                
                self.offset += self.count
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
}
