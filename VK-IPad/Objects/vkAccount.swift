//
//  vkAccount.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import RealmSwift

class vkAccount: Object {
    @objc dynamic var userID = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""
    @objc dynamic var avatarURL = ""
    @objc dynamic var screenName = ""
    @objc dynamic var lastSeen = 0
    @objc dynamic var token = ""
    @objc dynamic var appID = 0
    
    
    override static func primaryKey() -> String? {
        return "userID"
    }
}
