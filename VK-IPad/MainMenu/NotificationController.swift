//
//  NotificationController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 11.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class NotificationController: UITableViewController {

    var notifications: [Notification] = []
    
    var profiles: [UserProfile] = []
    var groups: [GroupProfile] = []
    var groupsInvite: [Groups] = []
    
    var newCount = 0
    var lastViewed = 0
    
    var readButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(self.updateNotifications), for: UIControlEvents.valueChanged)
        refreshControl?.tintColor = UIColor.black
        tableView.addSubview(refreshControl!)
        
        self.refreshControl?.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.separatorStyle = .none
        ViewControllerUtils().showActivityIndicator2(controller: self)
        
        getNotifications()
    }
    
    @objc func updateNotifications() {
        getNotifications()
    }

    func getNotifications() {
        
        notifications.removeAll(keepingCapacity: false)
        
        let url = "/method/notifications.get"
        let parameters = [
            "count": "100",
            "start_time": "\(Date().timeIntervalSince1970 - 15552000)",
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        let url2 = "/method/groups.getInvites"
        let parameters2 = [
            "count": "100",
            "extended": "1",
            "fields": "id, first_name, last_name, photo_100, sex",
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation2 = GetServerDataOperation(url: url2, parameters: parameters2)
        getServerDataOperation2.addDependency(getServerDataOperation)
        getServerDataOperation2.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let nots = json["response"]["items"].compactMap { Notification(json: $0.1) }
            
            self.profiles = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
            self.groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
            
            guard let data2 = getServerDataOperation2.data else { return }
            guard let json2 = try? JSON(data: data2) else { print("json error"); return }
            //print(json2)
            
            self.groupsInvite = json2["response"]["items"].compactMap { Groups(json: $0.1) }
            let profiles2 = json2["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
            
            for profile in profiles2 {
                self.profiles.append(profile)
            }
            
            for invite in self.groupsInvite {
                let not = Notification(json: JSON.null)
                not.type = "group_invite"
                not.feedbackCount = 1
                not.feedback[0].fromID = invite.invitedBy
                not.feedback[0].id = Int(invite.gid)!
                not.feedback[0].text = invite.name
                not.feedback[0].type = invite.typeGroup
                not.date = Int(Date().timeIntervalSince1970)
                self.notifications.append(not)
            }
            
            for not in nots {
                self.notifications.append(not)
            }
            
            self.newCount = 0
            var totalCount = 0
            self.lastViewed = json["response"]["last_viewed"].intValue
            for not in self.notifications {
                if not.date > self.lastViewed {
                    self.newCount += not.feedbackCount
                }
                if not.feedbackCount > 0 {
                    totalCount += not.feedbackCount
                } else {
                    totalCount += 1
                }
            }
            
            OperationQueue.main.addOperation {
                if totalCount > 0 {
                    self.navigationItem.title = "Ответы (\(totalCount))"
                } else {
                    self.navigationItem.title = "Ответы отсутствуют"
                }
                
                if self.newCount > 0 {
                    self.readButton = UIButton()
                    self.readButton.setTitle("Пометить как просмотренные", for: .normal)
                    self.readButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
                    self.readButton.setTitleColor(UIColor.white, for: .normal)
                    
                    self.readButton.layer.borderColor = UIColor.black.cgColor
                    self.readButton.layer.borderWidth = 0.6
                    self.readButton.layer.cornerRadius = 12
                    self.readButton.clipsToBounds = true
                    self.readButton.backgroundColor = vkSingleton.shared.mainColor
                    self.readButton.isEnabled = true
                    self.readButton.frame = CGRect(x: 200, y: 10, width: self.tableView.frame.width - 400, height: 25)
                    self.readButton.addTarget(self, action: #selector(self.readButtonClick(sender:)), for: .touchUpInside)
                    
                    let view = UIView()
                    view.addSubview(self.readButton)
                    view.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 45)
                    self.tableView.tableHeaderView = view
                } else {
                    self.tableView.tableHeaderView = nil
                }
                
                self.tableView.separatorStyle = .none
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        OperationQueue().addOperation(getServerDataOperation2)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return notifications.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications[section].feedbackCount
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.lightText
        if section == 0 && newCount > 0 {
            
            let label = UILabel()
            label.text = "Непросмотренные уведомления (\(newCount))"
            label.textAlignment = .center
            label.font = UIFont(name: "Verdana", size: 12.0)!
            label.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 15)
            view.addSubview(label)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && newCount > 0 {
            return 25
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var count = 0
        for index1 in 0...section {
            count += notifications[index1].feedbackCount
        }
        if count == newCount && newCount > 0 {
            return 0.01 //10
        }
        if section == tableView.numberOfSections - 1 {
            return 0.01
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notCell") as! NotificationCell
        
        if notifications.count > 0 {
            cell.delegate = self
            
            cell.not = notifications[indexPath.section]
            cell.users = profiles
            cell.groups = groups
            
            cell.indexPath = indexPath
            cell.cell = cell
            cell.tableView = self.tableView
            cell.cellWidth = self.tableView.bounds.width
            
            let height = cell.configureCell(calc: true)
        
            return height
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notCell", for: indexPath) as! NotificationCell
        
        if notifications.count > 0 {
            cell.delegate = self
            
            cell.not = notifications[indexPath.section]
            cell.users = profiles
            cell.groups = groups
            
            cell.indexPath = indexPath
            cell.cell = cell
            cell.tableView = self.tableView
            cell.cellWidth = self.tableView.bounds.width
            
            let _ = cell.configureCell(calc: false)
            
            if cell.not.date > lastViewed {
                cell.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.5)
            } else {
                cell.backgroundColor = UIColor.white
            }
        }
        
        return cell
    }
    
    @objc func readButtonClick(sender: UIButton!) {
        sender.buttonTouched()
        
        let alertController = UIAlertController(title: nil, message: "Пометить все новые уведомления как просмотренные?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Да", style: .destructive) { action in
            
            let url = "/method/notifications.markAsViewed"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "v": vkSingleton.shared.version
            ]
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            for group in self.groupsInvite {
                let url2 = "/method/groups.leave"
                let parameters2 = [
                    "group_id": group.gid,
                    "access_token": vkSingleton.shared.accessToken,
                    "v": vkSingleton.shared.version
                ]
                let request2 = GetServerDataOperation(url: url2, parameters: parameters2)
                request.addDependency(request2)
                OperationQueue().addOperation(request2)
            }
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    self.newCount = 0
                    self.notifications = self.notifications.filter({ $0.type != "group_invite" })
                    
                    OperationQueue.main.addOperation {
                        self.updateAppCounters()
                        self.getNotifications()
                    }
                } else {
                    self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
        alertController.addAction(OKAction)
        
        present(alertController, animated: true)
    }
}
