//
//  DialogsController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 04.09.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView

enum DialogsFilter: String {
    case all = "all"
    case unread = "unread"
    case important = "important"
    case unanswered = "unanswered"
}

class DialogsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var isRefresh = false
    
    var offset = 0
    var count = 30
    var totalCount = 0
    var unreadCount = 0
    var filter = DialogsFilter.all
    
    var conversations: [Conversation] = []
    var dialogs: [Dialog] = []
    var users: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        OperationQueue.main.addOperation {
            let updateButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.refreshConversation))
            self.navigationItem.rightBarButtonItem = updateButton
            
            self.title = self.segmentedControl.titleForSegment(at: 0)
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.separatorStyle = .none
            self.tableView.register(DialogsCell.self, forCellReuseIdentifier: "dialogsCell")
            
            self.getConversations()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dialogs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 3
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = vkSingleton.shared.backColor
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = vkSingleton.shared.backColor
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogsCell", for: indexPath) as! DialogsCell
        
        let dialog = dialogs[indexPath.section]
        
        cell.delegate = self
        cell.dialog = dialog
        cell.conversation = conversations.filter({ $0.peerID == dialog.peerID }).first
        cell.users = users
        cell.groups = groups
        
        cell.indexPath = indexPath
        
        cell.configureCell()
        cell.selectionStyle = .none
        
        let tap = UITapGestureRecognizer()
        tap.add {
            if cell.conversation.type == "user" || cell.conversation.type == "group" {
                self.openDialogController(ownerID: "\(dialog.peerID)", startID: dialog.id)
            }
            
            if cell.conversation.type == "chat" {
                self.openDialogController(ownerID: "\(dialog.peerID)", chatID: cell.conversation.localID, startID: dialog.id)
            }
        }
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(tap)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == tableView.numberOfSections-1 && offset < totalCount {
            isRefresh = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if isRefresh == false {
            self.getConversations()
        }
    }
    
    @objc func refreshConversation() {
        self.offset = 0
        self.getConversations()
    }
    
    func getConversations() {
        
        isRefresh = true
        ViewControllerUtils().showActivityIndicator2(controller: self)
        
        let url = "/method/messages.getConversations"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "offset": "\(offset)",
            "count": "\(count)",
            "filter": filter.rawValue,
            "extended": "1",
            "fields": "id,first_name,last_name,last_seen,photo_max_orig,photo_max,deactivated,first_name_abl,first_name_gen,last_name_gen,first_name_acc,last_name_acc,online,can_write_private_message,sex,photo_100",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            self.totalCount = json["response"]["count"].intValue
            self.unreadCount = json["response"]["unread_count"].intValue
            
            let conversations = json["response"]["items"].compactMap { Conversation(json: $0.1) }
            var dialogs: [Dialog] = []
            if conversations.count > 0 {
                for index in 0...conversations.count-1 {
                    let dialog = Dialog(json: JSON.null)
                    
                    dialog.id = json["response"]["items"][index]["last_message"]["id"].intValue
                    dialog.userID = json["response"]["items"][index]["last_message"]["user_id"].intValue
                    dialog.fromID = json["response"]["items"][index]["last_message"]["from_id"].intValue
                    dialog.peerID = json["response"]["items"][index]["last_message"]["peer_id"].intValue
                    dialog.date = json["response"]["items"][index]["last_message"]["date"].intValue
                    dialog.readState = json["response"]["items"][index]["last_message"]["read_state"].intValue
                    dialog.out = json["response"]["items"][index]["last_message"]["out"].intValue
                    dialog.emoji = json["response"]["items"][index]["last_message"]["emoji"].intValue
                    dialog.important = json["response"]["items"][index]["last_message"]["important"].intValue
                    dialog.deleted = json["response"]["items"][index]["last_message"]["deleted"].intValue
                    dialog.randomID = json["response"]["items"][index]["last_message"]["random_id"].intValue
                    dialog.title = json["response"]["items"][index]["last_message"]["title"].stringValue
                    dialog.body = json["response"]["items"][index]["last_message"]["text"].stringValue
                    
                    dialog.attachments = json["response"]["items"][index]["last_message"]["attachments"].compactMap({ Attachment(json: $0.1) })
                    dialog.fwdMessages = json["response"]["items"][index]["last_message"]["fwd_messages"].compactMap({ Dialog(json: $0.1) })
                    
                    let json2 = json["response"]["items"][index]["last_message"]["action"]
                    dialog.action = json2["type"].stringValue
                    dialog.actionID = json2["member_id"].intValue
                    dialog.actionEmail = json2["email"].stringValue
                    dialog.actionText = json2["text"].stringValue
                    
                    dialogs.append(dialog)
                }
            }
            
            let users = json["response"]["profiles"].compactMap { UserProfile(json: $0.1) }
            let groups = json["response"]["groups"].compactMap { GroupProfile(json: $0.1) }
            
            if self.offset == 0 {
                self.conversations = conversations
                self.dialogs = dialogs
                self.users = users
                self.groups = groups
            } else {
                self.conversations.append(contentsOf: conversations)
                self.dialogs.append(contentsOf: dialogs)
                self.users.append(contentsOf: users)
                self.groups.append(contentsOf: groups)
            }
            
            self.users.append(vkSingleton.shared.myProfile)
            
            OperationQueue.main.addOperation {
                self.offset += self.count
                self.tableView.reloadData()
                ViewControllerUtils().hideActivityIndicator()
            }
            
            self.setOfflineStatus(dependence: nil)
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    @IBAction func changeFilter(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.filter = DialogsFilter.all
            self.offset = 0
            self.title = sender.titleForSegment(at: 0)
            self.getConversations()
        case 1:
            self.filter = DialogsFilter.unread
            self.offset = 0
            self.title = sender.titleForSegment(at: 1)
            self.getConversations()
        case 2:
            self.filter = DialogsFilter.important
            self.offset = 0
            self.title = sender.titleForSegment(at: 2)
            self.getConversations()
        default:
            break
        }
    }
}
