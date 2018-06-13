//
//  ViewControllerProtocol.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import RealmSwift
import SCLAlertView
import SwiftyJSON

protocol ViewControllerProtocol {
    
    func setOfflineStatus(dependence: Operation?)
    
    func showErrorMessage(title: String, msg: String)
    
    func showSuccessMessage(title: String, msg: String)
    
    func showInfoMessage(title: String, msg: String)
    
    func updateAccountInRealm(account: vkAccount)
    
    func deleteAccountFromRealm(userID: Int)
    
    func getAccessTokenFromRealm(userID: Int) -> String
    
    func getNumberOfAccounts() -> Int
}

extension UIViewController: ViewControllerProtocol {
    
    func setOfflineStatus(dependence: Operation?) {
        if AppConfig.shared.setOfflineStatus {
            let url = "/method/account.setOffline"
            let parameters = [ "access_token": vkSingleton.shared.accessToken,
                               "v": vkSingleton.shared.version ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            if let operation = dependence {
                request.addDependency(operation)
            }
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                let result = json["response"].intValue
                
                if result == 1 {
                    print("offline: succesful")
                } else {
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    print("#\(error.errorCode): \(error.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        } else {
            let url = "/method/account.setOnline"
            let parameters = [ "access_token": vkSingleton.shared.accessToken,
                               "v": vkSingleton.shared.version ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            if let operation = dependence {
                request.addDependency(operation)
            }
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                let result = json["response"].intValue
                
                if result == 1 {
                    print("online: succesful")
                } else {
                    let error = ErrorJson(json: JSON.null)
                    error.errorCode = json["error"]["error_code"].intValue
                    error.errorMsg = json["error"]["error_msg"].stringValue
                    print("#\(error.errorCode): \(error.errorMsg)")
                }
            }
            OperationQueue().addOperation(request)
        }
    }
    
    func showErrorMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("OK", action: {})
            alert.showError(title, subTitle: msg)
        }
    }
    
    func showSuccessMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("OK", action: {})
            alert.showSuccess(title, subTitle: msg)
        }
    }
    
    func showInfoMessage(title: String, msg: String) {
        
        OperationQueue.main.addOperation {
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: UIScreen.main.bounds.width - 40,
                kTitleFont: UIFont(name: "Verdana", size: 13)!,
                kTextFont: UIFont(name: "Verdana", size: 12)!,
                kButtonFont: UIFont(name: "Verdana-Bold", size: 12)!,
                showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.addButton("OK", action: {})
            alert.showInfo(title, subTitle: msg)
        }
    }
    
    func updateAccountInRealm(account: vkAccount) {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            
            let realm = try Realm(configuration: config)
            
            //print(realm.configuration.fileURL!)
            
            realm.beginWrite()
            realm.add(account, update: true)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func deleteAccountFromRealm(userID: Int) {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            
            let realm = try Realm(configuration: config)
            
            let account = realm.objects(vkAccount.self).filter("userID == %@", userID)
            
            realm.beginWrite()
            realm.delete(account)
            try realm.commitWrite()
        } catch {
            print(error)
        }
    }
    
    func getAccessTokenFromRealm(userID: Int) -> String {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            
            let realm = try Realm(configuration: config)
            
            let realmAccounts = realm.objects(vkAccount.self).filter("userID == %@", userID)
            
            
            let accounts = Array(realmAccounts)
            if accounts.count > 0 {
                return accounts[0].token
            }
        } catch {
            print(error)
        }
        
        return ""
    }
    
    func getNumberOfAccounts() -> Int {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            
            let realm = try Realm(configuration: config)
            
            let realmAccounts = realm.objects(vkAccount.self)
            let accounts = Array(realmAccounts)
            return accounts.count
        } catch {
            print(error)
        }
        
        return 0
    }
}


