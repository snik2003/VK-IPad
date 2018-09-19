//
//  GroupsListController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 15.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class GroupsListController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: UIViewController!
    
    
    var userID = ""
    var type = ""
    var source = ""
    
    var isSearch = false
    
    var groups: [Groups] = []
    var searchGroups: [Groups] = []
    var groupsList: [Groups] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        OperationQueue.main.addOperation {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.searchBar.delegate = self
            self.searchBar.returnKeyType = .search
            self.searchBar.searchBarStyle = UISearchBarStyle.minimal
            self.searchBar.showsCancelButton = false
            self.searchBar.sizeToFit()
            self.searchBar.placeholder = ""
            self.searchBar.showsCancelButton = false
            
            if self.userID == vkSingleton.shared.userID && self.type == "" && self.source == "" {
                
                let actionButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.tapActionButton(sender:)))
                self.navigationItem.rightBarButtonItem = actionButton
            }
            
            self.tableView.separatorStyle = .none
            if self.type != "search" {
                ViewControllerUtils().showActivityIndicator(uiView: self.view)
            }
            
            if self.type == "invites" {
                self.tableView.isEditing = true
            } else {
                self.tableView.isEditing = false
            }
        }
        
        refresh()
        StoreReviewHelper.checkAndAskForReview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh() {
        let opq = OperationQueue()
        
        if type != "search" {
            
            var url = "/method/groups.get"
            var parameters = [
                "user_id": userID,
                "access_token": vkSingleton.shared.accessToken,
                "extended": "1",
                "fields": "name,cover,members_count,type,is_closed,deactivated,invited_by",
                "v": vkSingleton.shared.version
            ]
            
            if type == "groups" {
                parameters = [
                    "user_id": userID,
                    "access_token": vkSingleton.shared.accessToken,
                    "filter": "groups",
                    "extended": "1",
                    "fields": "name,cover,members_count,type,is_closed,deactivated,invited_by",
                    "v": vkSingleton.shared.version
                ]
            }
            
            if type == "pages" {
                parameters = [
                    "user_id": userID,
                    "access_token": vkSingleton.shared.accessToken,
                    "filter": "publics",
                    "extended": "1",
                    "fields": "name,cover,members_count,type,is_closed,deactivated,invited_by",
                    "v": vkSingleton.shared.version
                ]
            }
            
            if type == "admin" {
                parameters = [
                    "user_id": userID,
                    "access_token": vkSingleton.shared.accessToken,
                    "filter": "moder",
                    "extended": "1",
                    "fields": "name,cover,members_count,type,is_closed,deactivated,invited_by",
                    "v": vkSingleton.shared.version
                ]
            }
            
            if type == "invites" {
                url = "/method/groups.getInvites"
                parameters = [
                    "count": "100",
                    "extended": "1",
                    "fields": "name,cover,members_count,type,is_closed,deactivated,invited_by",
                    "access_token": vkSingleton.shared.accessToken,
                    "v": vkSingleton.shared.version
                ]
            }
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            opq.addOperation(getServerDataOperation)
            
            let parseGroups = ParseGroupList()
            parseGroups.addDependency(getServerDataOperation)
            opq.addOperation(parseGroups)
            
            let reloadTableController = ReloadGroupsListController(controller: self)
            reloadTableController.addDependency(parseGroups)
            OperationQueue.main.addOperation(reloadTableController)
        }
    }
    
    @objc func tapCancelButton(sender: UIBarButtonItem) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showInvites(sender: UIBarButtonItem) {
        
    }
    
    func refreshSearch() {
        OperationQueue.main.addOperation {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        let text = searchBar.text!
        let opq = OperationQueue()
        
        let url = "/method/groups.search"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "q": text,
            "type": "group,page,event",
            "count": "1000",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        opq.addOperation(getServerDataOperation)
        
        let parseGroups = ParseGroupList()
        parseGroups.addDependency(getServerDataOperation)
        opq.addOperation(parseGroups)
        
        let reloadTableController = ReloadGroupsListController(controller: self)
        reloadTableController.addDependency(parseGroups)
        OperationQueue.main.addOperation(reloadTableController)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 10
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 10
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupsCell", for: indexPath)
        
        let group = groupsList[indexPath.row]
        
        cell.textLabel?.text = group.name
        
        if group.deactivated != "" {
            if group.deactivated == "deleted" {
                cell.detailTextLabel?.text = "Сообщество удалено"
            } else {
                cell.detailTextLabel?.text = "Сообщество заблокировано"
            }
        } else {
            if group.typeGroup == "group" {
                if group.isClosed == 0 {
                    cell.detailTextLabel?.text = "Открытая группа"
                } else if group.isClosed == 1 {
                    cell.detailTextLabel?.text = "Закрытая группа"
                } else {
                    cell.detailTextLabel?.text = "Частная группа"
                }
            } else if group.typeGroup == "page" {
                cell.detailTextLabel?.text = "Публичная страница"
            } else {
                cell.detailTextLabel?.text = "Мероприятие"
            }
        }
        
        let getCacheImage = GetCacheImage(url: group.coverURL, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            cell.imageView?.layer.cornerRadius = 24.0
            cell.imageView?.clipsToBounds = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
            for index in visibleIndexPath {
                if index == indexPath {
                    let group = groupsList[indexPath.row]
                    
                    
                    /*if source == "add_mention" {
                        var mention = "[club\(group.gid)|\(group.name)]"
                        if group.typeGroup == "page" {
                            mention = "[public\(group.gid)|\(group.name)]"
                        } else if group.typeGroup == "event" {
                            mention = "[event\(group.gid)|\(group.name)]"
                        }
                        if let vc = delegate as? NewRecordController {
                            vc.textView.insertText(mention)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else if source == "add_comment_mention" {
                        var mention = "[club\(group.gid)|\(group.name)]"
                        if group.typeGroup == "page" {
                            mention = "[public\(group.gid)|\(group.name)]"
                        } else if group.typeGroup == "event" {
                            mention = "[event\(group.gid)|\(group.name)]"
                        }
                        if let vc = delegate as? NewCommentController {
                            vc.textView.insertText(mention)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else if source == "add_topic_mention" {
                        var mention = "[club\(group.gid)|\(group.name)]"
                        if group.typeGroup == "page" {
                            mention = "[public\(group.gid)|\(group.name)]"
                        } else if group.typeGroup == "event" {
                            mention = "[event\(group.gid)|\(group.name)]"
                        }
                        if let vc = delegate as? AddTopicController {
                            vc.textView.insertText(mention)
                        }
                        self.navigationController?.popViewController(animated: true)
                    } else {*/
                    
                    if source == "add_mention" {
                        var mention = "[club\(group.gid)|\(group.name)]"
                        if group.typeGroup == "page" {
                            mention = "[public\(group.gid)|\(group.name)]"
                        } else if group.typeGroup == "event" {
                            mention = "[event\(group.gid)|\(group.name)]"
                        }
                        
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
                    } else {
                        self.openProfileController(id: -1 * Int(group.gid)!, name: group.name)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if type == "invites" {
            return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if type == "invites" {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Отклонить\nприглашение") { (rowAction, indexPath) in
                
                let group = self.groupsList[indexPath.row]
                
                let url = "/method/groups.leave"
                
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "group_id": group.gid,
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
                            self.groupsList.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            
                            self.updateAppCounters()
                        }
                    } else {
                        self.delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                    }
                }
                OperationQueue().addOperation(request)
            }
            deleteAction.backgroundColor = .red
            
            let joinAction = UITableViewRowAction(style: .normal, title: "Принять\nприглашение") { (rowAction, indexPath) in
                
                let group = self.groupsList[indexPath.row]
                
                let url = "/method/groups.join"
                
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "group_id": group.gid,
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
                            self.groupsList.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            
                            self.updateAppCounters()
                        }
                    } else {
                        self.delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                    }
                }
                OperationQueue().addOperation(request)
            }
            joinAction.backgroundColor = .blue
            
            let gotoAction = UITableViewRowAction(style: .normal, title: "Перейти\nв сообщество") { (rowAction, indexPath) in
                
                let group = self.groupsList[indexPath.row]
                
                if let id = Int("-\(group.gid)") {
                    self.openProfileController(id: id, name: group.name)
                }
            }
            gotoAction.backgroundColor = .orange
            
            return [joinAction, deleteAction, gotoAction]
        }
        
        return []
    }

    @objc func tapActionButton(sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        if vkSingleton.shared.adminGroups.count > 0 {
            let action1 = UIAlertAction(title: "Поиск нового сообщества", style: .default) { action in
                
                self.openGroupsListController(uid: vkSingleton.shared.userID, title: "Поиск сообщества", type: "search")
            }
            alertController.addAction(action1)
        }
        
        if vkSingleton.shared.adminGroups.count > 0 {
            let action2 = UIAlertAction(title: "Управление сообществами", style: .default) { action in
                
                self.openGroupsListController(uid: vkSingleton.shared.userID, title: "Управление сообществами", type: "admin")
            }
            alertController.addAction(action2)
        }
        
        let action3 = UIAlertAction(title: "Входящие приглашения", style: .default) { action in
                
            self.openGroupsListController(uid: vkSingleton.shared.userID, title: "Новые приглашения в сообщества", type: "invites")
        }
        alertController.addAction(action3)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender
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
        
        if type != "search" {
            searchGroups = groups.filter({ $0.name.containsIgnoringCase(find: searchText) })
            
            if searchGroups.count == 0 {
                groupsList = groups
                isSearch = false
            } else {
                groupsList = searchGroups
                isSearch = true
            }
            
            self.tableView.reloadData()
        } else {
            refreshSearch()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchBar.endEditing(true)
    }
}
