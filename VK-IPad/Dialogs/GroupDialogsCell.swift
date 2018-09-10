//
//  GroupDialogsCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 10.09.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class GroupDialogsCell: UITableViewCell {

    var delegate: GroupDialogsController!
    var conversation: Conversation!
    var dialog: Dialog!
    var users: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    var indexPath: IndexPath!
    
    func configureCell() {
        
        self.removeAllSubviews()
        self.drawAvatar()
        
        if dialog.action == "" {
            self.drawLastMessageView()
        } else {
            self.drawLastActionView()
        }
        
        self.setUnreadValue(value: conversation.unreadCount)
        
        if conversation.readState {
            self.backgroundColor = delegate.tableView.backgroundColor
        } else {
            self.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
        }
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
            status = "групповая беседа (\(conversation.chatSettings.membersCount.membersAdder()))"
            statusColor = .black
            
            if avatarURL == "" {
                avatarURL = "https://vk.com/images/community_100.png"
            }
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
            avatarImage.layer.borderWidth = 0 //0.8
        }
        
        avatarImage.frame = CGRect(x: 10, y: 5, width: 70, height: 70)
        self.addSubview(avatarImage)
        
        let nameLabel = UILabel()
        nameLabel.tag = 250
        nameLabel.text = avatarName
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 14)
        nameLabel.frame = CGRect(x: 90, y: 0, width: self.bounds.width - 160, height: 20)
        self.addSubview(nameLabel)
        
        let statusLabel = UILabel()
        statusLabel.tag = 250
        statusLabel.text = status
        statusLabel.textColor = statusColor
        statusLabel.isEnabled = false
        if statusColor == .blue {
            statusLabel.isEnabled = true
        }
        statusLabel.font = UIFont(name: "Verdana", size: 11)
        statusLabel.frame = CGRect(x: 90, y: 18, width: self.bounds.width - 160, height: 17)
        self.addSubview(statusLabel)
    }
    
    func drawLastMessageView() {
        
        let width: CGFloat = self.bounds.width - 160
        
        let view = UIView()
        view.tag = 250
        
        var url = ""
        if dialog.fromID > 0 {
            if let user = self.users.filter({ $0.uid == "\(dialog.fromID)" }).first {
                url = user.photo100
            }
        } else if dialog.fromID < 0 {
            if let group = self.groups.filter({ $0.gid == abs(dialog.fromID) }).first {
                url = group.photo100
            }
        }
        
        let avatarImage = UIImageView()
        avatarImage.image = UIImage(named: "nophoto")
        avatarImage.contentMode = .scaleAspectFill
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: self, imageView: avatarImage, indexPath: indexPath, tableView: delegate.tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            avatarImage.layer.cornerRadius = 20
            avatarImage.clipsToBounds = true
            avatarImage.contentMode = .scaleAspectFill
            avatarImage.layer.borderColor = UIColor.lightGray.cgColor
            avatarImage.layer.borderWidth = 0 //0.4
        }
        
        avatarImage.frame = CGRect(x: 0, y: 2, width: 40, height: 40)
        view.addSubview(avatarImage)
        
        let messLabel = UILabel()
        messLabel.text = dialog.lastMessage
        messLabel.font = UIFont(name: "Verdana", size: 12)
        messLabel.numberOfLines = 0
        messLabel.frame = CGRect(x: 45, y: 0, width: width - 50, height: 30)
        view.addSubview(messLabel)
        
        let dateLabel = UILabel()
        dateLabel.text = "отправлено \(dialog.date.toStringLastTime())"
        dateLabel.isEnabled = false
        dateLabel.font = UIFont(name: "Verdana", size: 10)
        dateLabel.frame = CGRect(x: 45, y: 28, width: width - 50, height: 15)
        view.addSubview(dateLabel)
        
        view.frame = CGRect(x: 90, y: 35, width: width, height: 45)
        self.addSubview(view)
    }
    
    func drawLastActionView() {
        
        let width: CGFloat = self.bounds.width - 160
        
        let view = UIView()
        view.tag = 250
        
        var url = ""
        if dialog.fromID > 0 {
            if let user = self.users.filter({ $0.uid == "\(dialog.fromID)" }).first {
                url = user.photo100
            }
        } else if dialog.fromID < 0 {
            if let group = self.groups.filter({ $0.gid == abs(dialog.fromID) }).first {
                url = group.photo100
            }
        }
        
        let avatarImage = UIImageView()
        avatarImage.image = UIImage(named: "nophoto")
        avatarImage.contentMode = .scaleAspectFill
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        let setImageToRow = SetImageToRowOfTableView(cell: self, imageView: avatarImage, indexPath: indexPath, tableView: delegate.tableView)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            avatarImage.layer.cornerRadius = 20
            avatarImage.clipsToBounds = true
            avatarImage.contentMode = .scaleAspectFill
            avatarImage.layer.borderColor = UIColor.lightGray.cgColor
            avatarImage.layer.borderWidth = 0 //0.4
        }
        
        avatarImage.frame = CGRect(x: 0, y: 2, width: 40, height: 40)
        view.addSubview(avatarImage)
        
        var text = "Служебное сообщение..."
        if let user = self.users.filter({ $0.uid == "\(dialog.fromID)" }).first {
            
            var actUser = UserProfile(json: JSON.null)
            if dialog.actionID > 0, let user = self.users.filter({ $0.uid == "\(dialog.actionID)" }).first {
                actUser = user
            }
            
            if dialog.action == "chat_kick_user" {
                if dialog.actionID == dialog.fromID {
                    if user.sex == 1 {
                        text = "\(user.firstName) \(user.lastName) покинула беседу"
                    } else {
                        text = "\(user.firstName) \(user.lastName) покинул беседу"
                    }
                } else if dialog.actionID > 0 {
                    if user.sex == 1 {
                        text = "\(user.firstName) \(user.lastName) иcключила \(actUser.firstNameAcc) \(actUser.lastNameAcc) из беседы"
                    } else {
                        text = "\(user.firstName) \(user.lastName) иcключил \(actUser.firstNameAcc) \(actUser.lastNameAcc) из беседы"
                    }
                }
            } else if dialog.action == "chat_invite_user" {
                if dialog.actionID == dialog.fromID {
                    if user.sex == 1 {
                        text = "\(user.firstName) \(user.lastName) присоединилась к беседе"
                    } else {
                        text = "\(user.firstName) \(user.lastName) присоединился к беседе"
                    }
                } else if dialog.actionID > 0 {
                    if user.sex == 1 {
                        text = "\(user.firstName) \(user.lastName) пригласила в беседу \(actUser.firstNameAcc) \(actUser.lastNameAcc)"
                    } else {
                        text = "\(user.firstName) \(user.lastName) пригласил в беседу \(actUser.firstNameAcc) \(actUser.lastNameAcc)"
                    }
                }
            } else if dialog.action == "chat_invite_user_by_link" {
                if user.sex == 1 {
                    text = "\(user.firstName) \(user.lastName) присоединилась к беседе по ссылке"
                } else {
                    text = "\(user.firstName) \(user.lastName) присоединился к беседе по ссылке"
                }
            } else if dialog.action == "chat_create" {
                if user.sex == 1 {
                    text = "\(user.firstName) \(user.lastName) создала беседу с названием «\(dialog.actionText)»"
                } else {
                    text = "\(user.firstName) \(user.lastName) создал беседу с названием «\(dialog.actionText)»"
                }
            } else if dialog.action == "chat_title_update" {
                if user.sex == 1 {
                    text = "\(user.firstName) \(user.lastName) изменила название беседы на «\(dialog.actionText)»"
                } else {
                    text = "\(user.firstName) \(user.lastName) изменил название беседы на «\(dialog.actionText)»"
                }
            } else if dialog.action == "chat_photo_update" {
                if user.sex == 1 {
                    text = "\(user.firstName) \(user.lastName) обновила главную фотографию беседы"
                } else {
                    text = "\(user.firstName) \(user.lastName) обновил главную фотографию беседы"
                }
            } else if dialog.action == "chat_photo_remove" {
                if user.sex == 1 {
                    text = "\(user.firstName) \(user.lastName) удалила главную фотографию беседы"
                } else {
                    text = "\(user.firstName) \(user.lastName) удалил главную фотографию беседы"
                }
            } else if dialog.action == "chat_pin_message" {
                if user.sex == 1 {
                    text = "\(actUser.firstName) \(actUser.lastName) закрепила сообщение в беседе"
                } else {
                    text = "\(actUser.firstName) \(actUser.lastName) закрепил сообщение в беседе"
                }
            } else if dialog.action == "chat_unpin_message" {
                if user.sex == 1 {
                    text = "\(actUser.firstName) \(actUser.lastName) открепила сообщение в беседе"
                } else {
                    text = "\(actUser.firstName) \(actUser.lastName) открепил сообщение в беседе"
                }
            }
        }
        let messLabel = UILabel()
        messLabel.text = text
        messLabel.font = UIFont(name: "Verdana", size: 12)
        messLabel.numberOfLines = 0
        messLabel.isEnabled = false
        messLabel.frame = CGRect(x: 45, y: 0, width: width - 50, height: 30)
        view.addSubview(messLabel)
        
        let dateLabel = UILabel()
        dateLabel.text = "отправлено \(dialog.date.toStringLastTime())"
        dateLabel.isEnabled = false
        dateLabel.font = UIFont(name: "Verdana", size: 10)
        dateLabel.frame = CGRect(x: 45, y: 28, width: width - 50, height: 15)
        view.addSubview(dateLabel)
        
        view.frame = CGRect(x: 90, y: 35, width: width, height: 45)
        self.addSubview(view)
    }
    
    func setUnreadValue(value: Int) {
        
        if value > 0 {
            let view = UIView()
            view.tag = 250
            view.backgroundColor = vkSingleton.shared.mainColor
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.cornerRadius = 12
            view.frame = CGRect(x: frame.width-60, y: frame.height/2-12, width: 40, height: 24)
            self.addSubview(view)
            
            let label = UILabel()
            label.tag = 250
            label.backgroundColor = UIColor.clear
            label.text = "\(value)"
            if value >= 100 {
                label.text = "99+"
            }
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont(name: "Verdana-Bold", size: 14)
            label.frame = CGRect(x: frame.width-60, y: frame.height/2-10, width: 40, height: 20)
            self.addSubview(label)
        }
    }
}
