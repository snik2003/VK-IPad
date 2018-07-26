//
//  AppConfig.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

final class AppConfig {
    static let shared = AppConfig()
    
    var firstAppear = "first"
    
    var pushNotificationsOn = false
    
    var pushNewMessage = true
    var pushComment = true
    var pushNewFriends = true
    var pushNots = true
    var pushLikes = true
    var pushMentions = true
    var pushFromGroups = true
    var pushNewPosts = true
    
    var showStartMessage = false
    
    var setOfflineStatus = true
    var readMessageInDialog = true
    var showTextEditInDialog = true
    
    var passwordOn = false
    var passwordDigits = "0000"
    var touchID = false
    
    func readConfig() {
        OperationQueue().addOperation {
            
            let userDefault = UserDefaults.standard
            if userDefault.string(forKey: "\(vkSingleton.shared.userID)_firstAppear") != nil {
                
                self.pushNotificationsOn = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushNotificationsOn")
                self.pushNewMessage = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushNewMessage")
                self.pushComment = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushComment")
                self.pushNewFriends = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushNewFriends")
                self.pushNots = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushNots")
                self.pushLikes = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushLikes")
                self.pushMentions = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushMentions")
                self.pushFromGroups = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushFromGroups")
                self.pushNewPosts = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_pushNewPosts")
                
                self.showStartMessage = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_showStartMessage")
                
                self.setOfflineStatus = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_setOfflineStatus")
                self.readMessageInDialog = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_readMessageInDialog")
                self.showTextEditInDialog = userDefault.bool(forKey: "\(vkSingleton.shared.userID)_showTextEditInDialog")
            }
            
            self.passwordOn = userDefault.bool(forKey: "passwordOn")
            self.touchID = userDefault.bool(forKey: "touchID")
            if let digits = userDefault.string(forKey: "passDigits") {
                self.passwordDigits = digits
            } else {
                self.passwordDigits = "0000"
            }
        }
    }
    
    func saveConfig() {
        
        let userDefault = UserDefaults.standard
        
        userDefault.set(self.pushNotificationsOn, forKey: "\(vkSingleton.shared.userID)_pushNotificationsOn")
        userDefault.set(self.pushNewMessage, forKey: "\(vkSingleton.shared.userID)_pushNewMessage")
        userDefault.set(self.pushComment, forKey: "\(vkSingleton.shared.userID)_pushComment")
        userDefault.set(self.pushNewFriends, forKey: "\(vkSingleton.shared.userID)_pushNewFriends")
        userDefault.set(self.pushNots, forKey: "\(vkSingleton.shared.userID)_pushNots")
        userDefault.set(self.pushLikes, forKey: "\(vkSingleton.shared.userID)_pushLikes")
        userDefault.set(self.pushMentions, forKey: "\(vkSingleton.shared.userID)_pushMentions")
        userDefault.set(self.pushFromGroups, forKey: "\(vkSingleton.shared.userID)_pushFromGroups")
        userDefault.set(self.pushNewPosts, forKey: "\(vkSingleton.shared.userID)_pushNewPosts")
        
        userDefault.set(self.showStartMessage, forKey: "\(vkSingleton.shared.userID)_showStartMessage")
        
        userDefault.set(self.setOfflineStatus, forKey: "\(vkSingleton.shared.userID)_setOfflineStatus")
        userDefault.set(self.readMessageInDialog, forKey: "\(vkSingleton.shared.userID)_readMessageInDialog")
        userDefault.set(self.showTextEditInDialog, forKey: "\(vkSingleton.shared.userID)_showTextEditInDialog")
        
        userDefault.setValue("first", forKey: "\(vkSingleton.shared.userID)_firstAppear")
        
        userDefault.set(self.passwordOn, forKey: "passwordOn")
        userDefault.set(self.touchID, forKey: "touchID")
        userDefault.set(self.passwordDigits, forKey: "passDigits")
        //userDefault.set("0000", forKey: "passDigits")
    }
}

enum AppConfiguration: String {
    case Debug = "Debug"
    case TestFlight = "TestFlight"
    case AppStore = "AppStore"
}

struct Config {
    
    private static let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var appConfiguration: AppConfiguration {
        if isDebug {
            return .Debug
        } else if isTestFlight {
            return .TestFlight
        } else {
            return .AppStore
        }
    }
}
