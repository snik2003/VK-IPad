//
//  TopicsListController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 30.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class TopicsListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var groupID: String = ""
    var group: GroupProfile!
    
    var topics: [Topic] = []
    var users: [UserProfile] = []
    
    var total = 0
    var canAddTopics = 0
    
    var order = 1
    var offset = 0
    var count = 30
    var isRefresh = false
    
    var searchBar: UISearchBar!
    var tableView: UITableView!
    var optButton: UIBarButtonItem!
    
    var width: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        OperationQueue.main.addOperation {
            self.createSearchBar()
            self.createTableView()
            
            self.searchBar.delegate = self
            self.searchBar.returnKeyType = .search
            self.searchBar.searchBarStyle = UISearchBarStyle.minimal
            self.searchBar.showsCancelButton = false
            self.searchBar.sizeToFit()
            self.searchBar.placeholder = ""
            
            self.optButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapBarButtonItem(sender:)))
            self.navigationItem.rightBarButtonItem = self.optButton
            
            self.tableView.separatorStyle = .none
        }
        
        getTopics()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getTopics() {
        isRefresh = true
        
        OperationQueue.main.addOperation {
            self.tableView.reloadData()
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        let url = "/method/board.getTopics"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(groupID)",
            "order": "\(order)",
            "offset": "\(offset)",
            "count": "\(count)",
            "extended": "1",
            "preview": "1",
            "preview_length": "200",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let topics = json["response"]["items"].compactMap { Topic(json: $0.1) }
            let users = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
            
            self.total = json["response"]["count"].intValue
            self.canAddTopics = json["response"]["can_add_topics"].intValue
            
            OperationQueue.main.addOperation {
                if self.offset == 0 {
                    self.topics = topics
                    self.users = users
                } else {
                    for topic in topics {
                        self.topics.append(topic)
                    }
                    for user in users {
                        self.users.append(user)
                    }
                }
                
                self.offset += self.count
                self.tableView.separatorStyle = .none
                self.tableView.reloadData()
                ViewControllerUtils().hideActivityIndicator()
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func createSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.width, height: 0))
        
        self.view.addSubview(searchBar)
    }
    
    func createTableView() {
        tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: searchBar.frame.maxY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - searchBar.frame.maxY)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(TopicCell.self, forCellReuseIdentifier: "topicCell")
        
        self.view.addSubview(tableView)
    }
    
    @objc func tapBarButtonItem(sender: UIBarButtonItem) {
        if topics.count > 0 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            if canAddTopics == 1 {
                let action1 = UIAlertAction(title: "Создать новую тему для обсуждения", style: .default) { action in
                    
                    
                }
                alertController.addAction(action1)
            }
            
            let action2 = UIAlertAction(title: "Изменить порядок сортировки тем", style: .default) { action in
                
                let alertController2 = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController2.addAction(cancelAction)
                
                let action1 = UIAlertAction(title: "По убыванию даты изменения     ", style: self.getAlertActionStyle(1)) { action in
                    
                    self.order = 1
                    self.topics.removeAll(keepingCapacity: false)
                    self.offset = 0
                    
                    self.getTopics()
                }
                alertController2.addAction(action1)
                
                let action2 = UIAlertAction(title: "По убыванию даты создания     ", style: self.getAlertActionStyle(2)) { action in
                    
                    self.order = 2
                    self.topics.removeAll(keepingCapacity: false)
                    self.offset = 0
                    
                    self.getTopics()
                }
                alertController2.addAction(action2)
                
                let action3 = UIAlertAction(title: "По возрастанию даты изменения", style: self.getAlertActionStyle(-1)) { action in
                    
                    self.order = -1
                    self.topics.removeAll(keepingCapacity: false)
                    self.offset = 0
                    
                    self.getTopics()
                }
                alertController2.addAction(action3)
                
                let action4 = UIAlertAction(title: "По возрастанию даты создания", style: self.getAlertActionStyle(-2)) { action in
                    
                    self.order = -2
                    self.topics.removeAll(keepingCapacity: false)
                    self.offset = 0
                    
                    self.getTopics()
                }
                alertController2.addAction(action4)
                
                if let popoverController = alertController2.popoverPresentationController {
                    popoverController.barButtonItem = self.optButton
                    popoverController.permittedArrowDirections = [.up]
                }
                
                self.present(alertController2, animated: true)
            }
            alertController.addAction(action2)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.barButtonItem = self.optButton
                popoverController.permittedArrowDirections = [.up]
            }
            
            present(alertController, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell") as! TopicCell
        
        cell.delegate = self
        cell.topic = topics[indexPath.section]
        cell.group = group
        cell.cellWidth = self.width
        
        return cell.configureCell(calc: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.backgroundColor = vkSingleton.shared.backColor
        
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath) as! TopicCell
        
        cell.delegate = self
        cell.topic = topics[indexPath.section]
        cell.group = group
        cell.users = users
        
        cell.cellWidth = self.width
        cell.indexPath = indexPath
        cell.cell = cell
        cell.tableView = self.tableView
        
            
        let _ = cell.configureCell(calc: false)
        
        cell.selectionStyle = .none
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections - 1 && indexPath.section == offset - 1 && offset < total {
            isRefresh = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            OperationQueue.main.addOperation {
                self.getTopics()
            }
        }
    }
    
    func getAlertActionStyle(_ order: Int) -> UIAlertActionStyle {
        
        if self.order == order {
            return .destructive
        } else {
            return .default
        }
    }
}
