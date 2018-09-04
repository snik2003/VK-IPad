//
//  DialogsCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 04.09.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class DialogsCell: UITableViewCell {

    var delegate: DialogsController!
    var conversation: Conversation!
    var dialog: Dialog!
    var users: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    var indexPath: IndexPath!
    
    func configureCell() {
        
        self.removeAllSubviews()
        self.drawAvatar()
    }
    
    func drawAvatar() {
        
        var avatarURL = ""
        var avatarName = ""
        var status = ""
        var statusColor = UIColor.black
        
        if conversation.type == "user" {
            let users = delegate.users.filter({ $0.uid == "\(dialog.peerID)" })
            if users.count > 0 {
                let user = users[0]
                avatarURL = user.maxPhotoOrigURL
                avatarName = "\(user.firstName) \(user.lastName)"
                
                if user.deactivated == "" {
                    if user.onlineStatus == 1 {
                        status = "онлайн"
                        if user.onlineMobile == 1 {
                            status = "онлайн (моб.)"
                        }
                        statusColor = .blue
                    } else {
                        if user.sex == 1 {
                            status = "заходила \(user.lastSeen.toStringLastTime())"
                        } else {
                            status = "заходил \(user.lastSeen.toStringLastTime())"
                        }
                        statusColor = .black
                    }
                } else {
                    if user.deactivated == "deleted" {
                        status = "страница удалена"
                    } else {
                        status = "страница заблокирована"
                    }
                    statusColor = .black
                }
            }
        } else if conversation.type == "group" {
            let groups = delegate.groups.filter({ $0.gid == abs(dialog.peerID) })
            if groups.count > 0 {
                let group = groups[0]
                avatarURL = group.photo100
                avatarName = group.name
                status = group.groupType()
                statusColor = .black
            }
        } else if conversation.type == "chat" {
            avatarURL = conversation.chatSettings.photo100
            avatarName = conversation.chatSettings.title
            status = conversation.chatSettings.membersCount.membersAdder()
            statusColor = .black
        }
        
        let avatarImage = UIImageView()
        avatarImage.tag = 250
        avatarImage.image = UIImage(named: "nophoto")
        avatarImage.contentMode = .scaleAspectFill
        
        let getCacheImage = GetCacheImage(url: avatarURL, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: self, imageView: avatarImage, indexPath: indexPath, tableView: delegate.tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            avatarImage.layer.cornerRadius = 35
            avatarImage.clipsToBounds = true
            avatarImage.contentMode = .scaleAspectFill
            avatarImage.layer.borderColor = UIColor.lightGray.cgColor
            avatarImage.layer.borderWidth = 0.8
        }
        
        avatarImage.frame = CGRect(x: 10, y: 5, width: 70, height: 70)
        self.addSubview(avatarImage)
        
        let nameLabel = UILabel()
        nameLabel.tag = 250
        nameLabel.text = avatarName
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 14)
        nameLabel.frame = CGRect(x: 90, y: 5, width: self.bounds.width - 100, height: 20)
        self.addSubview(nameLabel)
        
        let statusLabel = UILabel()
        statusLabel.tag = 250
        statusLabel.text = status
        statusLabel.textColor = statusColor
        statusLabel.isEnabled = true
        if statusColor != .blue {
            statusLabel.isEnabled = false
        }
        statusLabel.font = UIFont(name: "Verdana", size: 12)
        statusLabel.frame = CGRect(x: 90, y: 22, width: self.bounds.width - 100, height: 18)
        self.addSubview(statusLabel)
    }
}
