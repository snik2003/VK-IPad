//
//  vkSingleton.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

final class vkSingleton {
    static let shared = vkSingleton()
    
    let apiURL = "https://api.vk.com"
    let vkAppID: [String] = ["6604375"]
    let version = "5.71"
    let lpVersion = "3"
    
    var userID: String = ""
    var userAppID: Int = 0
    var accessToken: String = ""
    //var avatarURL: String = ""
    
    var groupToken: [Int: String] = [:]
    var adminGroupID: [Int] = []
    var commentFromGroup = 0
    
    var deviceToken = ""
    var deviceRegisterOnPush = false
    
    var errorCode = 0
    var errorMsg = ""
    
    var pushInfo: [AnyHashable: Any]? = nil
    
    let appOpenedCountKey = "APP_OPENED_COUNT"
    
    let mainColor = UIColor(displayP3Red: 5/255, green: 103/255, blue: 164/255, alpha: 1)
    let backColor = UIColor(displayP3Red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
    let onlineColor = UIColor(displayP3Red: 0/255, green: 193/255, blue: 255/255, alpha: 1)
    
    var myProfile: UserProfile!
    
    var supportGroupID = "-166099539"
}
