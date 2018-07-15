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
    
    var newCount = 0
    
    var readButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.addTarget(self, action: #selector(self.updateNotifications), for: UIControlEvents.valueChanged)
        refreshControl?.tintColor = UIColor.black
        tableView.addSubview(refreshControl!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        OperationQueue.main.addOperation {
            self.refreshControl?.beginRefreshing()
            self.tableView.separatorStyle = .none
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        getNotifications()
    }
    
    @objc func updateNotifications() {
        getNotifications()
    }

    func getNotifications() {
        
        let url = "/method/notifications.get"
        let parameters = [
            "count": "100",
            "start_time": "\(Date().timeIntervalSince1970 - 15552000)",
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            print(json)
            
            self.notifications = json["response"]["items"].compactMap { Notification(json: $0.1) }
            
            self.profiles = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
            self.groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
            
            self.newCount = 0
            var totalCount = 0
            let lastViewed = json["response"]["last_viewed"].intValue
            for not in self.notifications {
                if not.date > lastViewed {
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
                    self.tableView.separatorStyle = .singleLine
                } else {
                    self.navigationItem.title = "Ответы отсутствуют"
                    self.tableView.separatorStyle = .none
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
                
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
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
            label.contentMode = .center
            label.font = UIFont(name: "Verdana", size: 12.0)!
            label.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 15)
            view.addSubview(label)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && newCount > 0 {
            return 15
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var count = 0
        for index1 in 0...section {
            count += notifications[index1].feedbackCount
        }
        if count == newCount && newCount > 0 {
            return 10
        }
        if section == tableView.numberOfSections - 1 {
            return 0.01
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notCell") as! NotificationCell
        
        cell.delegate = self
        
        cell.not = notifications[indexPath.section]
        cell.users = profiles
        cell.groups = groups
        
        cell.indexPath = indexPath
        cell.cellWidth = self.tableView.bounds.width
        
        let height = cell.getRowHeight()
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "notCell", for: indexPath) as! NotificationCell
        
        cell.delegate = self
        
        cell.not = notifications[indexPath.section]
        cell.users = profiles
        cell.groups = groups
        
        cell.indexPath = indexPath
        cell.cell = cell
        cell.tableView = self.tableView
        cell.cellWidth = self.tableView.bounds.width
        
        cell.configureCell()
        
        return cell
    }
    
    @objc func readButtonClick(sender: UIButton!) {
        sender.buttonTouched()
    }
}
