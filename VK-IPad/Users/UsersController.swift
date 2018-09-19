//
//  UsersController.swift
//  VK-total
//
//  Created by Сергей Никитин on 27.02.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView
import BEMCheckBox
import SwiftyJSON

class UsersController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    weak var delegate: UIViewController!
    
    var userID = ""
    var type = "friends"
    var source = ""
    var isSearch = false
    
    var attachment = ""
    var attachImage: UIImage?
    
    var friends = [Friends]()
    var sortedFriends = [Friends]()
    
    var users = [Friends]()
    var searchUsers = [Friends]()
    var sections = [Sections]()
    
    let alphabet =  [
                    "А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л",
                    "М", "Н", "О", "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш",
                    "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я", "A", "B", "C", "D", "E", "F",
                    "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S",
                    "T", "U", "V", "W", "X", "Y", "Z" ]

    var chatUsers: [Int] = []
    var chatButton = UIBarButtonItem()
    var chatMarkCheck: [IndexPath: BEMCheckBox] = [:]
    var chatAdminID = ""
    
    var chat: Conversation2!
    
    var count = 1000
    var offset = 0
    var filters = ""
    var isRefresh = false
    
    var deleteButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        OperationQueue.main.addOperation {
            self.searchBar.delegate = self
            self.searchBar.returnKeyType = .search
            self.searchBar.searchBarStyle = UISearchBarStyle.minimal
            self.searchBar.showsCancelButton = false
            self.searchBar.sizeToFit()
            self.searchBar.placeholder = ""
            
            self.tableView.separatorStyle = .none
            
            if self.type == "requests" {
                self.deleteButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapDeleteAllRequests(sender:)))
                self.navigationItem.rightBarButtonItem = self.deleteButton
                self.tableView.isEditing = true
            }
        }
        
        refresh()
        StoreReviewHelper.checkAndAskForReview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func refresh() {
        let opq = OperationQueue()
        isRefresh = true
        
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        var url: String = ""
        var parameters: Parameters = [:]
        
        if type == "friends" || type == "commonFriends" {
            url = "/method/friends.get"
            parameters = [
                "user_id": self.userID,
                "access_token": vkSingleton.shared.accessToken,
                "order": "hints",
                "fields": "online,photo_max,last_seen,sex,is_friend,first_name_dat,last_name_dat",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseFriends = ParseFriendList()
            parseFriends.addDependency(getServerDataOperation)
            opq.addOperation(parseFriends)
            
            let reloadTableController = ReloadUsersController(controller: self, type: type)
            reloadTableController.addDependency(parseFriends)
            OperationQueue.main.addOperation(reloadTableController)
            
        } else if type == "followers" {
            url = "/method/users.getFollowers"
            parameters = [
                "user_id": userID,
                "offset": "0",
                "count": "1000",
                "access_token": vkSingleton.shared.accessToken,
                "fields": "online,photo_max,last_seen,sex,is_friend,first_name_dat,last_name_dat",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseFriends = ParseFriendList()
            parseFriends.addDependency(getServerDataOperation)
            opq.addOperation(parseFriends)
            
            let reloadTableController = ReloadUsersController(controller: self, type: type)
            reloadTableController.addDependency(parseFriends)
            OperationQueue.main.addOperation(reloadTableController)
            
        } else if type == "subscript" {
            let url1 = "/method/friends.getRequests"
            let parameters1 = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "0",
                "out": "1",
                "count": "1000",
                "fields": "online,photo_max,last_seen,sex,is_friend,first_name_dat,last_name_dat",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation1 = GetServerDataOperation(url: url1, parameters: parameters1)
            opq.addOperation(getServerDataOperation1)
            
            let parseRequest = ParseRequest()
            parseRequest.addDependency(getServerDataOperation1)
            parseRequest.completionBlock = {
                if parseRequest.count > 0 {
                    let listID = parseRequest.outputData
                    
                    url = "/method/users.get"
                    parameters = [
                        "user_ids": listID,
                        "access_token": vkSingleton.shared.accessToken,
                        "fields": "online,photo_max,last_seen,sex,is_friend,first_name_dat,last_name_dat",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                    opq.addOperation(getServerDataOperation)
                    
                    let parseFriends = ParseRequestList()
                    parseFriends.addDependency(getServerDataOperation)
                    opq.addOperation(parseFriends)
                    
                    let reloadTableController = ReloadUsersController(controller: self, type: self.type)
                    reloadTableController.addDependency(parseFriends)
                    OperationQueue.main.addOperation(reloadTableController)
                } else {
                    OperationQueue.main.addOperation {
                        self.segmentedControl.setTitle("Подписки: 0", forSegmentAt: 0)
                        self.segmentedControl.setTitle("Онлайн: 0", forSegmentAt: 1)
                        self.tableView.separatorStyle = .singleLine
                        self.tableView.reloadData()
                        ViewControllerUtils().hideActivityIndicator()
                    }
                }
            }
            opq.addOperation(parseRequest)
        } else if type == "requests" {
            let url1 = "/method/friends.getRequests"
            let parameters1 = [
                "access_token": vkSingleton.shared.accessToken,
                "offset": "0",
                "out": "0",
                "sort": "0",
                "count": "1000",
                "fields": "online,photo_max,last_seen,sex,is_friend,first_name_dat,last_name_dat",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation1 = GetServerDataOperation(url: url1, parameters: parameters1)
            opq.addOperation(getServerDataOperation1)
            
            let parseRequest = ParseRequest()
            parseRequest.addDependency(getServerDataOperation1)
            parseRequest.completionBlock = {
                if parseRequest.count > 0 {
                    let listID = parseRequest.outputData
                    
                    url = "/method/users.get"
                    parameters = [
                        "user_ids": listID,
                        "access_token": vkSingleton.shared.accessToken,
                        "fields": "online,photo_max,last_seen,sex,is_friend,first_name_dat,last_name_dat",
                        "v": vkSingleton.shared.version
                    ]
                    
                    let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                    opq.addOperation(getServerDataOperation)
                    
                    let parseFriends = ParseRequestList()
                    parseFriends.addDependency(getServerDataOperation)
                    opq.addOperation(parseFriends)
                    
                    let reloadTableController = ReloadUsersController(controller: self, type: self.type)
                    reloadTableController.addDependency(parseFriends)
                    OperationQueue.main.addOperation(reloadTableController)
                } else {
                    OperationQueue.main.addOperation {
                        self.segmentedControl.setTitle("Заявки: 0", forSegmentAt: 0)
                        self.segmentedControl.setTitle("Онлайн: 0", forSegmentAt: 1)
                        self.tableView.separatorStyle = .singleLine
                        self.tableView.reloadData()
                        ViewControllerUtils().hideActivityIndicator()
                    }
                }
            }
            opq.addOperation(parseRequest)
        } else if type == "members" {
            let url = "/method/groups.getMembers"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "group_id": "\(userID)",
                "sort": "id_desc",
                "offset": "\(offset)",
                "count": "\(count)",
                "fields": "online,photo_max,last_seen,sex,is_friend,first_name_dat,last_name_dat",
                "filter": filters,
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseFriends = ParseFriendList()
            parseFriends.addDependency(getServerDataOperation)
            opq.addOperation(parseFriends)
            
            let reloadTableController = ReloadUsersController(controller: self, type: type)
            reloadTableController.addDependency(parseFriends)
            OperationQueue.main.addOperation(reloadTableController)
        } else if type == "chat_users" {
            url = "/method/messages.getChat"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "chat_id": chat.localID,
                "fields": "id, first_name, last_name, last_seen, photo_max_orig, photo_max, deactivated, first_name_abl, first_name_gen, online,  can_write_private_message, sex",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            getServerDataOperation.completionBlock = {
                guard let data = getServerDataOperation.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                //print(json)
                
                
                self.chatAdminID = json["response"]["admin_id"].stringValue
                self.friends = json["response"]["users"].compactMap { Friends(json: $0.1) }
                self.sortedFriends = self.friends
                self.users = self.sortedFriends
                
                OperationQueue.main.addOperation {
                    let onlineCount = self.users.filter({ $0.onlineStatus == 1 }).count
                    
                    self.segmentedControl.setTitle("Участники: \(self.users.count)", forSegmentAt: 0)
                    self.segmentedControl.setTitle("Онлайн: \(onlineCount)", forSegmentAt: 1)
                    
                    self.tableView.separatorStyle = .singleLine
                    self.tableView.reloadData()
                    ViewControllerUtils().hideActivityIndicator()
                }
            }
            opq.addOperation(getServerDataOperation)
        }
    }

    @objc func tapDeleteAllRequests(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action = UIAlertAction(title: "Оставить все заявки в подписчиках", style: .default){ action in
            
            let url = "/method/friends.deleteAllRequests"
            
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        self.friends.removeAll(keepingCapacity: false)
                        self.tableView.reloadData()
                        
                        self.updateAppCounters()
                    }
                } else {
                    self.delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                }
            }
            OperationQueue().addOperation(request)
        }
        alertController.addAction(action)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = self.deleteButton
            popoverController.permittedArrowDirections = [.up]
        }
        
        self.present(alertController, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearch = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        isSearch = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchUsers = sortedFriends.filter({ "\($0.firstName) \($0.lastName)".containsIgnoringCase(find: searchText) })
        
        if searchUsers.count == 0 {
            if segmentedControl.selectedSegmentIndex == 0 {
                users = sortedFriends
            } else {
                users = sortedFriends.filter({ $0.onlineStatus == 1 })
            }
            
            if type == "folowers" {
                segmentedControl.setTitle("Подписчики: \(self.sortedFriends.count)", forSegmentAt: 0)
            } else if type.containsIgnoringCase(find: "friends") {
                segmentedControl.setTitle("Все друзья: \(self.sortedFriends.count)", forSegmentAt: 0)
            } else if type == "subscript" {
                segmentedControl.setTitle("Подписки: \(self.sortedFriends.count)", forSegmentAt: 0)
            } else if type == "requests" {
                segmentedControl.setTitle("Заявки: \(self.sortedFriends.count)", forSegmentAt: 0)
            } else if type == "chat_users" || type == "members" {
                segmentedControl.setTitle("Участники: \(self.sortedFriends.count)", forSegmentAt: 0)
            }
            segmentedControl.setTitle("Онлайн: \(self.sortedFriends.filter({ $0.onlineStatus == 1 }).count)", forSegmentAt: 1)
            
            isSearch = false
        } else {
            if segmentedControl.selectedSegmentIndex == 0 {
                users = searchUsers
            } else {
                users = searchUsers.filter({ $0.onlineStatus == 1 })
            }
            
            if type == "followers" {
                segmentedControl.setTitle("Подписчики: \(self.searchUsers.count)", forSegmentAt: 0)
            } else if type.containsIgnoringCase(find: "friends") {
                segmentedControl.setTitle("Все друзья: \(self.searchUsers.count)", forSegmentAt: 0)
            } else if type == "subscript" {
                segmentedControl.setTitle("Подписки: \(self.searchUsers.count)", forSegmentAt: 0)
            } else if type == "requests" {
                segmentedControl.setTitle("Заявки: \(self.searchUsers.count)", forSegmentAt: 0)
            } else if type == "chat_users" || type == "members" {
                segmentedControl.setTitle("Участники: \(self.searchUsers.count)", forSegmentAt: 0)
            }
            segmentedControl.setTitle("Онлайн: \(self.searchUsers.filter({ $0.onlineStatus == 1 }).count)", forSegmentAt: 1)
            
            isSearch = true
        }
        
        self.tableView.reloadData()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //self.searchBar.text = nil
        self.searchBar.endEditing(true)
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl)
    {
        users.removeAll(keepingCapacity: false)
        tableView.reloadData()
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        switch sender.selectedSegmentIndex {
        case 0:
            if isSearch {
                users = searchUsers
                
                sender.setTitle("Онлайн: \(self.searchUsers.filter({ $0.onlineStatus == 1 }).count)", forSegmentAt: 1)
            } else {
                users = sortedFriends
                sender.setTitle("Онлайн: \(self.sortedFriends.filter({ $0.onlineStatus == 1 }).count)", forSegmentAt: 1)
            }
            if type == "followers" {
                sender.setTitle("Подписчики: \(self.users.count)", forSegmentAt: 0)
            } else if type.containsIgnoringCase(find: "friends") {
                sender.setTitle("Все друзья: \(self.users.count)", forSegmentAt: 0)
            } else if type == "subscript" {
                sender.setTitle("Подписки: \(self.users.count)", forSegmentAt: 0)
            } else if type == "requests" {
                sender.setTitle("Заявки: \(self.users.count)", forSegmentAt: 0)
            } else if type == "chat_users" || type == "members" {
                sender.setTitle("Участники: \(self.users.count)", forSegmentAt: 0)
            }
        case 1:
            if isSearch {
                users = searchUsers.filter({ $0.onlineStatus == 1 })
                if type == "followers" {
                    sender.setTitle("Подписчики: \(self.searchUsers.count)", forSegmentAt: 0)
                } else if type.containsIgnoringCase(find: "friends") {
                    sender.setTitle("Все друзья: \(self.searchUsers.count)", forSegmentAt: 0)
                } else if type == "subscript" {
                    sender.setTitle("Подписки: \(self.searchUsers.count)", forSegmentAt: 0)
                } else if type == "requests" {
                    sender.setTitle("Заявки: \(self.searchUsers.count)", forSegmentAt: 0)
                } else if type == "chat_users" || type == "members" {
                    sender.setTitle("Участники: \(self.searchUsers.count)", forSegmentAt: 0)
                }
            } else {
                users = sortedFriends.filter({ $0.onlineStatus == 1 })
                if type == "followers" {
                    sender.setTitle("Подписчики: \(self.sortedFriends.count)", forSegmentAt: 0)
                } else if type.containsIgnoringCase(find: "friends") {
                    sender.setTitle("Все друзья: \(self.sortedFriends.count)", forSegmentAt: 0)
                } else if type == "subscript" {
                    sender.setTitle("Подписки: \(self.sortedFriends.count)", forSegmentAt: 0)
                } else if type == "requests" {
                    sender.setTitle("Заявки: \(self.sortedFriends.count)", forSegmentAt: 0)
                } else if type == "chat_users" || type == "members" {
                    sender.setTitle("Участники: \(self.sortedFriends.count)", forSegmentAt: 0)
                }
            }
            sender.setTitle("Онлайн: \(self.users.count)", forSegmentAt: 1)
        default:
            break
        }
        tableView.reloadData()
        if tableView.numberOfSections > 0, tableView.numberOfRows(inSection: 0) > 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        ViewControllerUtils().hideActivityIndicator()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let count = getNumberOfSection()
        if count == 0 {
            tableView.separatorStyle = .none
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch type {
        case "friends":
            return sections[section].countRows
        case "commonFriends":
            return sections[section].countRows
        case "followers":
            return sections[section].countRows
        case "subscript":
            return sections[section].countRows
        case "requests":
            return sections[section].countRows
        case "chat_users":
            return sections[section].countRows
        case "members":
            return sections[section].countRows
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if type == "friends" || type == "commonFriends" {
            return sections[section].letter
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if type == "friends" || type == "commonFriends" {
            return 16
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 10
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        
        viewFooter.backgroundColor = UIColor.white
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
            for index in visibleIndexPath {
                if index == indexPath {
                    let user = sections[indexPath.section].users[indexPath.row]
                    
                    if source == "add_mention" {
                        let mention = "[id\(user.userID)|\(user.firstName) \(user.lastName)]"
                        
                        if let controller = delegate as? RecordController {
                            controller.commentView.textView.insertText(mention)
                        } else if let controller = delegate as? VideoController {
                            controller.commentView.textView.insertText(mention)
                        } else if let controller = delegate as? TopicController {
                            controller.commentView.textView.insertText(mention)
                        } else if let controller = delegate as? DialogController {
                            controller.commentView.textView.insertText(mention)
                        } else if let controller = delegate as? NewRecordController {
                            controller.textView.insertText(mention)
                        }
                        
                        self.navigationController?.popViewController(animated: true)
                    } else if source == "invite" {
                        self.delegate.inviteFriendInGroup(friend: user)
                    } else if source == "add_to_chat" {
                        if let controller = delegate as? DialogController {
                            controller.addUserToChat(user: user)
                        }
                    } else {
                        self.openProfileController(id: Int(user.userID)!, name: "\(user.firstName) \(user.lastName)")
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if type == "requests" {
            return true
        }
        
        let user = self.sections[indexPath.section].users[indexPath.row]
        if type == "chat_users" && chatAdminID == vkSingleton.shared.userID && chatAdminID != user.userID {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if type == "requests" {
            let joinAction = UITableViewRowAction(style: .normal, title: "Принять заявку\nв друзья") { (rowAction, indexPath) in
                
                let user = self.sections[indexPath.section].users[indexPath.row]
                
                let url = "/method/friends.add"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "user_id": "\(user.uid)",
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url, parameters: parameters)
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        OperationQueue.main.addOperation {
                            self.friends.remove(object: user)
                            self.tableView.reloadData()
                            
                            self.updateAppCounters()
                        }
                    } else {
                        self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                    }
                }
                OperationQueue().addOperation(request)
            }
            joinAction.backgroundColor = .blue
            
            let gotoAction = UITableViewRowAction(style: .destructive, title: "Просмотреть\nпользователя") { (rowAction, indexPath) in
                
                let user = self.sections[indexPath.section].users[indexPath.row]
                if let id = Int(user.uid) {
                    self.openProfileController(id: id, name: "\(user.firstName) \(user.lastName)")
                }
            }
            gotoAction.backgroundColor = .orange
            
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Оставить в\nподписчиках") { (rowAction, indexPath) in
                
                let user = self.sections[indexPath.section].users[indexPath.row]
                
                let url = "/method/friends.delete"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "user_id": user.uid,
                    "v": vkSingleton.shared.version
                ]
                
                let request = GetServerDataOperation(url: url, parameters: parameters)
                request.completionBlock = {
                    guard let data = request.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    
                    if error.errorCode == 0 {
                        OperationQueue.main.addOperation {
                            self.friends.remove(object: user)
                            self.tableView.reloadData()
                            
                            self.updateAppCounters()
                        }
                    } else {
                        self.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                    }
                }
                OperationQueue().addOperation(request)
            }
            deleteAction.backgroundColor = .red
            
            return [joinAction, deleteAction, gotoAction]
        }
        
        if type == "chat_users" && chatAdminID == vkSingleton.shared.userID {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Исключить\nиз беседы") { (rowAction, indexPath) in
                
                print(self.delegate)
                print(self.chatAdminID)
                if let controller = self.delegate as? DialogController {
                    let user = self.sections[indexPath.section].users[indexPath.row]
                    controller.removeUserFromChat(user: user)
                }
                
            }
            deleteAction.backgroundColor = .red
            
            return [deleteAction]
        }
        
        return []
    }
    
    func openDialog(userID: String, attachment: String) {
        
        let url = "/method/messages.getHistory"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "0",
            "count": "1",
            "user_id": userID,
            "start_message_id": "-1",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        OperationQueue().addOperation(getServerDataOperation)
        
        /*let parseDialog = ParseDialogHistory()
        parseDialog.completionBlock = {
            var startID = parseDialog.inRead
            if parseDialog.outRead > startID {
                startID = parseDialog.outRead
            }
            OperationQueue.main.addOperation {
                self.navigationController?.popViewController(animated: true)
                self.openDialogController(userID: userID, chatID: "", startID: startID, attachment: attachment, messIDs: [], image: self.attachImage)
                
            }
        }
        parseDialog.addDependency(getServerDataOperation)
        OperationQueue().addOperation(parseDialog)*/
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath)
        
        for subview in cell.subviews {
            if subview.tag == 200 {
                subview.removeFromSuperview()
            }
        }
        
        switch type {
        case "friends","commonFriends","followers","subscript","requests","chat_users","members":
            
            let user = sections[indexPath.section].users[indexPath.row]
            
            if filters == "managers" {
                cell.textLabel?.text = "\(user.firstName) \(user.lastName) "
                
                if user.onlineStatus == 1 {
                    if user.onlineMobile == 1 {
                        let fullString = "\(user.firstName) \(user.lastName) "
                        cell.textLabel?.setOnlineMobileStatus(text: "\(fullString)", platform: user.platform)
                    } else {
                        let fullString = "\(user.firstName) \(user.lastName) ●"
                        let rangeOfColoredString = (fullString as NSString).range(of: "●")
                        let attributedString = NSMutableAttributedString(string: fullString)
                        
                        if let color = cell.textLabel?.tintColor {
                            attributedString.setAttributes([NSAttributedStringKey.foregroundColor:  color], range: rangeOfColoredString)
                        }
                        cell.textLabel?.attributedText = attributedString
                    }
                }
                
                if user.role == "moderator" {
                    cell.detailTextLabel?.text = "модератор"
                    cell.detailTextLabel?.textColor = UIColor.brown
                } else if user.role == "editor" {
                    cell.detailTextLabel?.text = "редактор"
                    cell.detailTextLabel?.textColor = UIColor.blue
                } else if user.role == "creator" {
                    cell.detailTextLabel?.text = "создатель сообщества"
                    cell.detailTextLabel?.textColor = UIColor.red
                } else {
                    cell.detailTextLabel?.text = "администратор"
                    cell.detailTextLabel?.textColor = UIColor.purple
                }
                cell.detailTextLabel?.isEnabled = true
            } else {
                cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
                
                if user.deactivated != "" {
                    if user.deactivated == "banned" {
                        cell.detailTextLabel?.text = "страница заблокирована"
                    }
                    if user.deactivated == "deleted" {
                        cell.detailTextLabel?.text = "страница удалена"
                    }
                    cell.detailTextLabel?.textColor = UIColor.black
                    cell.detailTextLabel?.isEnabled = false
                } else {
                    if user.onlineStatus == 1 {
                        cell.detailTextLabel?.text = "онлайн"
                        if user.onlineMobile == 1 {
                            cell.detailTextLabel?.text = "онлайн (моб.)"
                        }
                        cell.detailTextLabel?.textColor = UIColor.blue
                        cell.detailTextLabel?.isEnabled = true
                    } else {
                        if user.sex == 1 {
                            cell.detailTextLabel?.text = "заходила \(user.lastSeen.toStringLastTime())"
                        } else {
                            cell.detailTextLabel?.text = "заходил \(user.lastSeen.toStringLastTime())"
                        }
                        cell.detailTextLabel?.textColor = UIColor.black
                        cell.detailTextLabel?.isEnabled = false
                    }
                }
            }
            
            let getCacheImage = GetCacheImage(url: user.photoURL, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                cell.imageView?.layer.cornerRadius = 24.0
                cell.imageView?.clipsToBounds = true
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 30)
            cell.accessoryType = .disclosureIndicator
            
            if type == "chat_users" {
                if chatAdminID == user.userID {
                    let adminLabel = UILabel()
                    adminLabel.tag = 200
                    adminLabel.text = "создатель\nбеседы"
                    adminLabel.font = UIFont(name: "Verdana", size: 12)!
                    adminLabel.numberOfLines = 2
                    adminLabel.textAlignment = .center
                    adminLabel.textColor = UIColor.red
                    
                    adminLabel.layer.borderColor = UIColor.red.cgColor
                    adminLabel.layer.borderWidth = 0.8
                    adminLabel.layer.cornerRadius = 6
                    
                    adminLabel.frame = CGRect(x: cell.bounds.width - 120, y: 9, width: 100, height: 32)
                    
                    cell.addSubview(adminLabel)
                }
                
                cell.accessoryType = .none
            }
            
            if self.source == "create_chat" {
                let markCheck = BEMCheckBox()
                markCheck.tag = 200
                markCheck.onTintColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                markCheck.onCheckColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                markCheck.lineWidth = 2
                markCheck.isEnabled = false
                if let id = Int(user.userID) {
                    markCheck.on = chatUsers.contains(id)
                }
                markCheck.frame = CGRect(x: cell.bounds.width - 40, y: cell.bounds.height/2 - 10, width: 20, height: 20)
                cell.addSubview(markCheck)
                chatMarkCheck[indexPath] = markCheck
                
                cell.accessoryType = .none
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 && indexPath.row == offset - 1 && segmentedControl.selectedSegmentIndex == 0 {
            isRefresh = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false && type == "members" {
            refresh()
        }
    }
    
    @objc func showRequests(sender: UIBarButtonItem) {
        self.openUsersController(uid: vkSingleton.shared.userID, title: "Непринятые заявки в друзья", type: "requests")
    }
    
    func getNumberOfSection() -> Int {
        
        sections.removeAll(keepingCapacity: false)
        var num = 0
        
        if userID == vkSingleton.shared.userID && isSearch == false && friends.count > 0 && segmentedControl.selectedSegmentIndex == 0 && type == "friends" && source != "create_chat"{
            var users = [Friends]()
            var count = 0
            if friends.count >= 5 {
                for index in 0...4 {
                    users.append(friends[index])
                }
                count = 5
            } else {
                for index in 0...friends.count - 1 {
                    users.append(friends[index])
                }
                count = friends.count
            }
            num = 1
            let section = Sections(num: num - 1, letter: "Важные", count: count, users: users)
            sections.append(section)
        }
        
        if type == "followers" || type == "subscript" || type == "members"{
            num = 1
            let section = Sections(num: num - 1, letter: "", count: users.count, users: users)
            sections.append(section)
        } else {
            for alf in alphabet {
                let users = self.users.filter( { $0.lastName.prefix(1).uppercased() == alf } )
                if users.count > 0 {
                    num += 1
                    let section = Sections(num: num - 1, letter: alf, count: users.count, users: users)
                    sections.append(section)
                }
            }
        }
        
        return num
    }
}

class Sections {
    var numSection: Int
    var letter: String
    var countRows: Int
    var users: [Friends]
    
    init(num: Int, letter: String, count: Int, users: [Friends]) {
        self.numSection = num
        self.letter = letter
        self.countRows = count
        self.users = users
    }
}
