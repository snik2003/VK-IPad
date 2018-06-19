//
//  GroupProfile.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 15.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

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
}

struct Contact {
    var userID: Int = 0
    var desc: String = ""
    var phone: String = ""
    var email: String = ""
}
