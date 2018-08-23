//
//  GroupProfile.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 15.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON
import Popover

class GroupProfile {
    var gid: Int = 0
    var name: String = ""
    var screenName: String = ""
    var isClosed: Int = 0
    var deactivated: String = ""
    var isAdmin: Int = 0
    var levelAdmin: Int = 0
    var isMember: Int = 0
    var type: String = ""
    var photo50: String = ""
    var photo100: String = ""
    var photo200: String = ""
    var activity: String = ""
    var membersCounter: Int = 0
    var photosCounter: Int = 0
    var albumsCounter: Int = 0
    var audiosCounter: Int = 0
    var videosCounter: Int = 0
    var topicsCounter: Int = 0
    var docsCounter: Int = 0
    var isCover: Int = 0
    var coverUrl: String = ""
    var coverWidth: Int = 0
    var coverHeight: Int = 0
    var description: String = ""
    var hasPhoto: Int = 0
    var memberStatus: Int = 0
    var site: String = ""
    var status: String = ""
    var isFavorite: Int = 0
    var canPost: Int = 0
    var isHiddenFromFeed = 0
    var canMessage: Int = 0
    var verified: Int = 0
    var contacts: [Contact] = []
    
    init(json: JSON) {
        gid = json["id"].intValue
        name = json["name"].stringValue
        screenName = json["screen_name"].stringValue
        isClosed = json["is_closed"].intValue
        deactivated = json["deactivated"].stringValue
        isAdmin = json["is_admin"].intValue
        levelAdmin = json["admin_level"].intValue
        isMember = json["is_member"].intValue
        type = json["type"].stringValue
        photo50 = json["photo_50"].stringValue
        photo100 = json["photo_100"].stringValue
        photo200 = json["photo_200"].stringValue
        activity = json["activity"].stringValue
        membersCounter = json["members_count"].intValue
        photosCounter = json["counters"]["photos"].intValue
        albumsCounter = json["counters"]["albums"].intValue
        audiosCounter = json["counters"]["audios"].intValue
        videosCounter = json["counters"]["videos"].intValue
        topicsCounter = json["counters"]["topics"].intValue
        docsCounter = json["counters"]["docs"].intValue
        isCover = json["cover"]["enabled"].intValue
        coverUrl = json["cover"]["images"][2]["url"].stringValue
        coverWidth = json["cover"]["images"][2]["width"].intValue
        coverHeight = json["cover"]["images"][2]["height"].intValue
        description = json["description"].stringValue
        hasPhoto = json["has_photo"].intValue
        memberStatus = json["member_status"].intValue
        site = json["site"].stringValue
        status = json["status"].stringValue
        isFavorite = json["is_favorite"].intValue
        canPost = json["can_post"].intValue
        canMessage = json["can_message"].intValue
        isHiddenFromFeed = json["is_hidden_from_feed"].intValue
        verified = json["verified"].intValue
        
        for index in 0...9 {
            var contact = Contact()
            contact.userID = json["contacts"][index]["user_id"].intValue
            if contact.userID > 0 {
                contact.desc = json["contacts"][index]["desc"].stringValue
                contact.phone = json["contacts"][index]["phone"].stringValue
                contact.email = json["contacts"][index]["email"].stringValue
                self.contacts.append(contact)
            }
        }
    }
}

struct Contact {
    var userID: Int = 0
    var desc: String = ""
    var phone: String = ""
    var email: String = ""
}

extension GroupProfile {
    
    func groupType() -> String {
        
        if self.deactivated != "" {
            if self.deactivated == "banned" {
                return "Сообщество заблокировано"
            }
            if self.deactivated == "deleted" {
                return "Сообщество удалено"
            }
        } else if self.type == "group" {
            if self.isClosed == 0 {
                return "Открытая группа"
            } else {
                return "Закрытая группа"
            }
        } else if self.type == "page" {
            return "Публичная страница"
        } else if self.type == "event" {
            return "Мероприятие"
        }
        
        return ""
    }
    
    func memberButtonText() -> String {
        
        if self.isAdmin > 0 {
            if self.levelAdmin == 1 {
                return "Вы модератор"
            } else if self.levelAdmin == 2 {
                return "Вы редактор"
            } else if self.levelAdmin == 3 {
                return "Вы администратор"
            }
        } else if self.isMember == 1 {
            if self.type == "group" {
                return "Вы участник"
            } else if self.type == "page" {
                return "Вы подписаны"
            } else {
                return "Вы участвуете"
            }
        } else {
            if self.type == "group" {
                if self.isClosed == 0 {
                    return "Вступить в группу"
                } else {
                    return "Отправить заявку"
                }
            } else if self.type == "page" {
                return "Подписаться"
            } else {
                return "Принять участие"
            }
        }
        
        return ""
    }
    
    var contactList: String {
        
        var contactsIDs = ""
        for contact in self.contacts {
            if contactsIDs != "" {
                contactsIDs = "\(contactsIDs),"
            }
            contactsIDs = "\(contactsIDs)\(contact.userID)"
        }
        return contactsIDs
    }
    
    func showContactsView(delegate: UIViewController, point: CGPoint) {
        
        let url = "/method/users.get"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "user_ids": self.contactList,
            "fields": "id,first_name,last_name,last_seen,photo_max_orig,deactivated,online,sex",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let users = json["response"].compactMap { UserProfile(json: $0.1) }
            
            OperationQueue.main.addOperation {
                let contactsView = UIView()
            
                var width: CGFloat = 0
                var height: CGFloat = 20
                
                for contact in self.contacts {
                    let user = users.filter({ $0.uid == "\(contact.userID)" })
                    if user.count > 0 {
                        let view = self.contactView(delegate: delegate, user: user[0], contact: contact, topY: height)
                        contactsView.addSubview(view)
                        height += view.frame.height
                        if view.frame.width > width {
                            width = view.frame.width
                        }
                    }
                }
                
                
                //height += 10
                contactsView.frame = CGRect(x: 0, y: 0, width: width + 20, height: height)
            
                let popoverOptions: [PopoverOption] = [
                    //.arrowSize(CGSize.zero),
                    .type(.down),
                    .cornerRadius(6),
                    .color(UIColor.white),
                    .blackOverlayColor(UIColor.gray.withAlphaComponent(0.75))
                ]
                
                let popover = Popover(options: popoverOptions)
                popover.show(contactsView, point: point, inView: delegate.view)
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func contactView(delegate: UIViewController, user: UserProfile, contact: Contact, topY: CGFloat) -> UIView {
        
        let view = UIView()
        
        let maxWidth: CGFloat = 600
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        let nameFont = UIFont(name: "Verdana-Bold", size: 14)!
        let contactFont = UIFont(name: "Verdana", size: 12)!
        
        let getCacheImage = GetCacheImage(url: user.maxPhotoOrigURL, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                let avatarImage = UIImageView()
                avatarImage.image = getCacheImage.outputImage
                avatarImage.clipsToBounds = true
                avatarImage.layer.cornerRadius = 19
                avatarImage.frame = CGRect(x: 10, y: 5, width: 40, height: 40)
                avatarImage.contentMode = .scaleAspectFill
                view.addSubview(avatarImage)
            }
        }
        OperationQueue().addOperation(getCacheImage)
        
        var start: CGFloat = 15
        if contact.desc != "" {
            start += 15
        }
        if contact.phone != "" {
            start += 15
        }
        if contact.email != "" {
            start += 15
        }
        var startX: CGFloat = 0
        if start < 40 {
            startX = (40 - start) / 2
        }
        
        let nameLabel = UILabel()
        nameLabel.attributedText = nil
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        if user.onlineStatus == 1 {
            if user.onlineMobile == 1 {
                let fullString = "\(user.firstName) \(user.lastName) "
                nameLabel.setOnlineMobileStatus(text: "\(fullString)", platform: user.platform)
            } else {
                let fullString = "\(user.firstName) \(user.lastName) ●"
                let rangeOfColoredString = (fullString as NSString).range(of: "●")
                let attributedString = NSMutableAttributedString(string: fullString)
                
                attributedString.setAttributes([NSAttributedStringKey.foregroundColor: nameLabel.tintColor], range: rangeOfColoredString)
                
                nameLabel.attributedText = attributedString
            }
        }
        nameLabel.font = nameFont
        let size = delegate.getTextSize(text: nameLabel.text!, font: nameFont, maxWidth: maxWidth)
        width = size.width + 20
        nameLabel.frame = CGRect(x: 60, y: 5 + startX, width: size.width + 20, height: 15)
        view.addSubview(nameLabel)
        height += 20 + startX
        
        if contact.desc != "" {
            let label = UILabel()
            label.text = "\(contact.desc)"
            label.font = contactFont
            let size = delegate.getTextSize(text: label.text!, font: contactFont, maxWidth: maxWidth)
            if size.width > width {
                width = size.width
            }
            label.frame = CGRect(x: 60, y: height, width: size.width, height: 15)
            view.addSubview(label)
            height += 15
        }
        
        if contact.phone != "" {
            let label = UILabel()
            label.text = "\(contact.phone)"
            label.font = contactFont
            let size = delegate.getTextSize(text: label.text!, font: contactFont, maxWidth: maxWidth)
            if size.width > width {
                width = size.width
            }
            label.frame = CGRect(x: 60, y: height, width: size.width, height: 15)
            view.addSubview(label)
            height += 15
        }
        
        if contact.email != "" {
            let label = UILabel()
            label.text = "\(contact.email)"
            label.font = contactFont
            let size = delegate.getTextSize(text: label.text!, font: contactFont, maxWidth: maxWidth)
            if size.width > width {
                width = size.width
            }
            label.frame = CGRect(x: 60, y: height, width: size.width, height: 15)
            view.addSubview(label)
            height += 15
        }
        
        height = max(height, 50.0)
        width = max(width, 200.0)
        
        view.frame = CGRect(x: 5, y: topY, width: 60 + width + 10, height: height)
        
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.add {
            delegate.openProfileController(id: contact.userID, name: "\(user.firstName) \(user.lastName)")
        }
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
        return view
    }
}
