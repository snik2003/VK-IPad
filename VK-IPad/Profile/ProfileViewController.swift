//
//  ProfileViewController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class ProfileViewController: UITableViewController, WKNavigationDelegate {

    var userProfile: [UserProfile] = []
    var photos: [Photo] = []
  
    var heights: [IndexPath: CGFloat] = [:]
    var recordsCount: Int = 0
    
    var userID = vkSingleton.shared.userID
    
    var offset = 0
    let count = 20
    var filterRecords = "owner"
    
    var wall: [Record] = []
    var wallProfiles: [UserProfile] = []
    var wallGroups: [GroupProfile] = []
    
    var postponedWall: [Record] = []
    var postponedWallProfiles: [UserProfile] = []
    var postponedWallGroups: [GroupProfile] = []
    
    var isRefresh = false
    var viewFirstAppear = true
    
    var profileView: ProfileView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        OperationQueue.main.addOperation {
            self.refreshControl?.addTarget(self, action: #selector(self.pullToRefresh), for: UIControlEvents.valueChanged)
            self.refreshControl?.tintColor = UIColor.gray
            self.tableView.addSubview(self.refreshControl!)
            
            ViewControllerUtils().showActivityIndicator2(controller: self)
        }
        
        self.view.layoutIfNeeded()
        refreshExecute()
        StoreReviewHelper.checkAndAskForReview()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !viewFirstAppear {
            self.refreshUserInfo()
        }
        viewFirstAppear = false
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
            if self.filterRecords == "postponed" {
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
        refreshExecute()
    }
    
    func refreshExecute() {
        
        isRefresh = true
        heights.removeAll(keepingCapacity: false)
        self.tableView.separatorStyle = .none
        
        var code = "var a = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_id\":\"\(userID)\",\"fields\":\"id,first_name,last_name,maiden_name,domain,sex,relation,bdate,home_town,has_photo,city,country,status,last_seen,online,photo_max_orig,photo_max,photo_id,followers_count,counters,deactivated,education,contacts,connections,site,about,interests,activities,books,games,movies,music,tv,quotes,first_name_abl,first_name_gen,first_name_dat,first_name_acc,first_name_ins,last_name_abl,last_name_gen,last_name_dat,last_name_acc,last_name_ins,can_post,can_send_friend_request,can_write_private_message,friend_status,is_favorite,blacklisted,blacklisted_by_me,crop_photo,is_hidden_from_feed,wall_default,personal,relatives,can_see_all_posts\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var b = API.photos.getAll({\"owner_id\":\"\(userID)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"extended\":1,\"count\":100,\"photo_sizes\":0,\"skip_hidden\":0,\"v\": \"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var c = API.wall.get({\"owner_id\":\(userID),\"offset\":\(offset),\"access_token\": \"\(vkSingleton.shared.accessToken)\",\"count\":\(count),\"filter\":\"\(filterRecords)\",\"extended\":1,\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var d = API.wall.get({\"owner_id\":\(userID),\"offset\":\(offset),\"access_token\": \"\(vkSingleton.shared.accessToken)\",\"count\":\(count),\"filter\":\"postponed\",\"extended\":1,\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
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
            
            self.userProfile = json["response"][0].compactMap { UserProfile(json: $0.1) }
            self.photos = json["response"][1]["items"].compactMap { Photo(json: $0.1) }
            
            //print(json["response"][2])
            
            if self.userProfile.count > 0 {
                let user = self.userProfile[0]
                if user.blacklisted == 1 {
                    self.showErrorMessage(title: "Предупреждение", msg: "\nВы находитесь в черном списке \(user.firstNameGen)\n")
                }
            }
            
            self.postponedWall = json["response"][3]["items"].compactMap { Record(json: $0.1) }
            self.postponedWallProfiles = json["response"][3]["profiles"].compactMap { UserProfile(json: $0.1) }
            self.postponedWallGroups = json["response"][3]["groups"].compactMap { GroupProfile(json: $0.1) }
            
            let wallData = json["response"][2]["items"].compactMap { Record(json: $0.1) }
            let profilesData = json["response"][2]["profiles"].compactMap { UserProfile(json: $0.1) }
            let groupsData = json["response"][2]["groups"].compactMap { GroupProfile(json: $0.1) }
            
            self.recordsCount = json["response"][2]["count"].intValue
            
            if self.offset == 0 {
                self.wall = wallData
                self.wallProfiles = profilesData
                self.wallGroups = groupsData
            } else {
                for record in wallData {
                    self.wall.append(record)
                }
                for group in groupsData {
                    self.wallGroups.append(group)
                }
                for profile in profilesData {
                    self.wallProfiles.append(profile)
                }
            }
            
            self.offset += self.count
            
            OperationQueue.main.addOperation {
                self.setProfileView()
                self.tableView.reloadData()
                
                if self.userProfile.count > 0 {
                    let user = self.userProfile[0]
                    self.title = "\(user.firstName) \(user.lastName)"
                }
                
                self.refreshControl?.endRefreshing()
                ViewControllerUtils().hideActivityIndicator()
                
                if let userInfo = vkSingleton.shared.pushInfo {
                    vkSingleton.shared.pushInfo = nil
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        appDelegate.tapPushNotification(userInfo, controller: self)
                    }
                }
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
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
        if userProfile.count > 0 {
            profileView = ProfileView()
            profileView.backgroundColor = vkSingleton.shared.backColor
            
            profileView.delegate = self
            profileView.user = userProfile[0]
            profileView.photos = photos
            
            let height: CGFloat = profileView.configureView(more: false)
            
            
            profileView.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: height)
            
            self.tableView.tableHeaderView = profileView
        }
    }
    
    func refreshWall(filter: String) {
        if userProfile.count > 0 {
            isRefresh = true
            ViewControllerUtils().showActivityIndicator2(controller: self)
            heights.removeAll(keepingCapacity: false)
            filterRecords = filter
            recordsCount = 0
            
            if filterRecords == "others" && userProfile[0].canSeeAllPosts == 0 {
                wall.removeAll(keepingCapacity: false)
                wallGroups.removeAll(keepingCapacity: false)
                wallProfiles.removeAll(keepingCapacity: false)
                
                profileView.updateOwnerButtons()
                profileView.recordsCountLabel.text = "Нет записей"
                
                offset += self.count
                tableView.reloadData()
                refreshControl?.endRefreshing()
                ViewControllerUtils().hideActivityIndicator()
            } else {
                let url = "/method/wall.get"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": userID,
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
                        if self.recordsCount > 0 {
                            self.profileView.recordsCountLabel.text = "Всего записей: \(self.recordsCount)"
                        } else {
                            self.profileView.recordsCountLabel.text = "Нет записей"
                        }
                        
                        self.offset += self.count
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                        ViewControllerUtils().hideActivityIndicator()
                    }
                }
                OperationQueue().addOperation(getServerDataOperation)
            }
        }
    }
    
    func refreshUserInfo() {
        let opq = OperationQueue()
        
        let url = "/method/users.get"
        let parameters = [
            "user_id": userID,
            "access_token": vkSingleton.shared.accessToken,
            "fields": "id,first_name,last_name,maiden_name,domain,sex,relation,bdate,home_town,has_photo,city,country,status,last_seen,online,photo_max_orig,photo_max,photo_id,followers_count,counters,deactivated,education,contacts,connections,site,about,interests,activities,books,games,movies,music,tv,quotes,first_name_abl,first_name_gen,first_name_dat,first_name_acc,first_name_ins,last_name_abl,last_name_gen,last_name_dat,last_name_acc,last_name_ins,can_post,can_send_friend_request,can_write_private_message,friend_status,is_favorite,blacklisted,blacklisted_by_me,crop_photo,is_hidden_from_feed,wall_default,personal,relatives,can_see_all_posts",
            "name_case": "nom",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            self.userProfile = json["response"].compactMap { UserProfile(json: $0.1) }
            if self.userProfile.count > 0 {
                OperationQueue.main.addOperation {
                    if self.userProfile[0].onlineStatus == 1 {
                        self.profileView.lastLabel.text = " онлайн"
                        self.profileView.lastLabel.textColor = UIColor.blue
                        self.profileView.lastLabel.isEnabled = true
                    } else {
                        if self.userProfile[0].deactivated == "" {
                            self.profileView.lastLabel.text = " заходил " + self.userProfile[0].lastSeen.toStringLastTime()
                            if self.userProfile[0].sex == 1 {
                                self.profileView.lastLabel.text = " заходила " + self.userProfile[0].lastSeen.toStringLastTime()
                            }
                        }
                        self.profileView.lastLabel.isEnabled = false
                    }
                    
                    if self.userProfile[0].platform > 0 && self.userProfile[0].platform != 7 {
                        self.profileView.lastLabel.setPlatformStatus(text: "\(self.profileView.lastLabel.text!)", platform: self.userProfile[0].platform, online: self.userProfile[0].onlineStatus)
                    }
                }
            }
        }
        opq.addOperation(getServerDataOperation)
    }
}
