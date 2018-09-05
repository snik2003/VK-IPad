//
//  DialogTitleView.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 24.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DialogTitleView: UIView {

    var delegate: DialogController!
    var status = ""
    
    var conversation: Conversation2!
    var user: UserProfile!
    var group: GroupProfile!
    
    let nameFont = UIFont(name: "Verdana-Bold", size: 15)
    let onlineFont = UIFont(name: "Verdana-Bold", size: 11)
    let offlineFont = UIFont(name: "Verdana", size: 12)
    
    func configure() {
        
        var url = ""
        var parameters: Parameters = [:]
        
        if delegate.chatID == 0 {
            if let id = Int(delegate.userID), id > 0 {
                url = "/method/users.get"
                parameters = [
                    "user_id": delegate.userID,
                    "access_token": vkSingleton.shared.accessToken,
                    "fields": "id,first_name,last_name,maiden_name,domain,sex,relation,bdate,home_town,has_photo,city,country,status,last_seen,online,photo_max_orig,photo_max,photo_id,followers_count,counters,deactivated,education,contacts,connections,site,about,interests,activities,books,games,movies,music,tv,quotes,first_name_abl,first_name_gen,first_name_dat,first_name_acc,first_name_ins,last_name_abl,last_name_gen,last_name_dat,last_name_acc,last_name_ins,can_post,can_send_friend_request,can_write_private_message,friend_status,is_favorite,blacklisted,blacklisted_by_me,crop_photo,is_hidden_from_feed,wall_default,personal,relatives,can_see_all_posts",
                    "name_case": "nom",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                getServerDataOperation.completionBlock = {
                    guard let data = getServerDataOperation.data else { return }
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let users = json["response"].compactMap { UserProfile(json: $0.1) }
                    if users.count > 0 {
                        OperationQueue.main.addOperation {
                            self.user = users[0]
                            self.configureUserView()
                            
                            self.delegate.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self)
                            self.delegate.title = ""
                            
                            let tap = UITapGestureRecognizer()
                            self.isUserInteractionEnabled = true
                            self.addGestureRecognizer(tap)
                            tap.add {
                                self.delegate.tapDialogTitleView()
                            }
                        }
                    }
                }
                OperationQueue().addOperation(getServerDataOperation)
            }
            
            if let id = Int(delegate.userID), id < 0 {
                url = "/method/groups.getById"
                parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "group_id": "\(abs(id))",
                    "fields": "activity,counters,cover,description,has_photo,member_status,site,status,members_count,is_favorite,can_post,is_hidden_from_feed,can_message,contacts,verified",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                getServerDataOperation.completionBlock = {
                    guard let data = getServerDataOperation.data else { return }
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    
                    let groups = json["response"].compactMap { GroupProfile(json: $0.1) }
                    if groups.count > 0 {
                        OperationQueue.main.addOperation {
                            self.group = groups[0]
                            self.configureGroupView()
                            self.delegate.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self)
                            self.delegate.title = ""
                            
                            let tap = UITapGestureRecognizer()
                            self.isUserInteractionEnabled = true
                            self.addGestureRecognizer(tap)
                            tap.add {
                                self.delegate.tapDialogTitleView()
                            }
                        }
                    }
                }
                OperationQueue().addOperation(getServerDataOperation)
            }
        } else {
            
            url = "/method/messages.getConversationsById"
            parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "peer_ids": "\(delegate.userID)",
                "extended": "0",
                "v": vkSingleton.shared.version
            ]
            
            let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
            getServerDataOperation.completionBlock = {
                guard let data = getServerDataOperation.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let conversations = json["response"]["items"].compactMap { Conversation2(json: $0.1) }
                if conversations.count > 0 {
                    OperationQueue.main.addOperation {
                        self.conversation = conversations[0]
                        self.configureChatView()
                        
                        self.delegate.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self)
                        self.delegate.title = ""
                        
                        let tap = UITapGestureRecognizer()
                        self.isUserInteractionEnabled = true
                        self.addGestureRecognizer(tap)
                        tap.add {
                            self.delegate.tapChatTitleView()
                        }
                    }
                }
            }
            OperationQueue().addOperation(getServerDataOperation)
        }
    }

    func configureUserView() {
        
        self.frame = CGRect(x: delegate.view.frame.width - 400, y: 8, width: 400, height: 40)
        
        let imageView = UIImageView()
        let getCacheImage = GetCacheImage(url: user.maxPhotoOrigURL, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                imageView.image = getCacheImage.outputImage
                imageView.layer.cornerRadius = 19
                imageView.layer.borderWidth = 1.2
                imageView.layer.borderColor = UIColor.white.cgColor
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: 364, y: 1, width: 38, height: 38)
                imageView.contentMode = .scaleAspectFill
            }
        }
        OperationQueue().addOperation(getCacheImage)
        self.addSubview(imageView)
        
        
        let nameLabel = UILabel()
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.4
        nameLabel.textAlignment = .right
        nameLabel.textColor = UIColor.white
        nameLabel.font = nameFont
        nameLabel.frame = CGRect(x: 0, y: 3, width: 350, height: 20)
        self.addSubview(nameLabel)
        
        
        let statusLabel = UILabel()
        statusLabel.text = user.statusLane
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.4
        statusLabel.textAlignment = .right
        if user.onlineStatus == 1 {
            statusLabel.textColor = vkSingleton.shared.onlineColor
            statusLabel.font = onlineFont
        } else {
            statusLabel.textColor = UIColor.white
            statusLabel.font = offlineFont
        }
        statusLabel.frame = CGRect(x: 0, y: 21, width: 350, height: 16)
        self.addSubview(statusLabel)
    }
    
    func configureGroupView() {
        
        self.frame = CGRect(x: delegate.view.frame.width - 400, y: 8, width: 400, height: 40)
        
        let imageView = UIImageView()
        let getCacheImage = GetCacheImage(url: group.photo100, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                imageView.image = getCacheImage.outputImage
                imageView.layer.cornerRadius = 19
                imageView.layer.borderWidth = 1.2
                imageView.layer.borderColor = UIColor.white.cgColor
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: 364, y: 1, width: 38, height: 38)
                imageView.contentMode = .scaleAspectFill
            }
        }
        OperationQueue().addOperation(getCacheImage)
        self.addSubview(imageView)
        
        let nameLabel = UILabel()
        nameLabel.text = group.name
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.4
        nameLabel.textAlignment = .right
        nameLabel.textColor = UIColor.white
        nameLabel.font = nameFont
        nameLabel.frame = CGRect(x: 0, y: 3, width: 350, height: 20)
        self.addSubview(nameLabel)
        
        
        let statusLabel = UILabel()
        statusLabel.text = group.groupType()
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.4
        statusLabel.textAlignment = .right
        statusLabel.textColor = UIColor.white
        statusLabel.font = offlineFont
        statusLabel.frame = CGRect(x: 0, y: 20, width: 350, height: 16)
        self.addSubview(statusLabel)
    }
    
    func configureChatView() {
        
        self.frame = CGRect(x: delegate.view.frame.width - 400, y: 8, width: 400, height: 40)
        
        var url = conversation.chatSettings.photo100
        if url == "" {
            url = "https://vk.com/images/community_100.png"
        }
        
        let imageView = UIImageView()
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                imageView.image = getCacheImage.outputImage
                imageView.layer.cornerRadius = 19
                imageView.layer.borderWidth = 1.2
                imageView.layer.borderColor = UIColor.white.cgColor
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: 364, y: 1, width: 38, height: 38)
                imageView.contentMode = .scaleAspectFill
            }
        }
        OperationQueue().addOperation(getCacheImage)
        self.addSubview(imageView)
        
        let nameLabel = UILabel()
        nameLabel.text = conversation.chatSettings.title
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.4
        nameLabel.textAlignment = .right
        nameLabel.textColor = UIColor.white
        nameLabel.font = nameFont
        nameLabel.frame = CGRect(x: 0, y: 3, width: 350, height: 20)
        self.addSubview(nameLabel)
        
        
        let statusLabel = UILabel()
        statusLabel.text = "Групповой чат (\(conversation.chatSettings.membersCount.membersAdder()))"
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.4
        statusLabel.textAlignment = .right
        statusLabel.textColor = UIColor.white
        statusLabel.font = offlineFont
        statusLabel.frame = CGRect(x: 0, y: 20, width: 350, height: 16)
        self.addSubview(statusLabel)
    }
}
