//
//  MenuViewController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class MenuViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshUserInfo()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }
    
    func refreshUserInfo() {
        
        let url = "/method/users.get"
        let parameters = [
            "user_id": vkSingleton.shared.userID,
            "access_token": vkSingleton.shared.accessToken,
            "fields": "id,first_name,last_name,domain,last_seen,online,photo_max_orig,photo_max,deactivated,sex",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let userProfile = json["response"].compactMap { UserProfile(json: $0.1) }
            //print(json["response"][0])
            
            OperationQueue.main.addOperation {
                if userProfile.count > 0 {
                    let user = userProfile[0]
                    self.navigationController?.navigationBar.setupUserProfileView(user: user)
                    
                    if user.uid == vkSingleton.shared.userID {
                        self.saveAccountToRealm(user: user)
                    }
                }
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func saveAccountToRealm(user: UserProfile) {
        
        let account = vkAccount()
    
        account.userID = Int(user.uid)!
        account.token = vkSingleton.shared.accessToken
        account.firstName = user.firstName
        account.lastName = user.lastName
        account.screenName = user.domain
        account.lastSeen = user.lastSeen
        account.avatarURL = user.maxPhotoOrigURL
        account.appID = vkSingleton.shared.userAppID
        self.updateAccountInRealm(account: account)
    }
}

extension UINavigationBar {
    func setupUserProfileView(user: UserProfile) {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        
        let imageView = UIImageView()
        let getCacheImage = GetCacheImage(url: user.maxPhotoOrigURL, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                imageView.image = getCacheImage.outputImage
                imageView.layer.cornerRadius = 20
                imageView.layer.borderWidth = 1
                imageView.layer.borderColor = UIColor.lightGray.cgColor
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: 2, y: 2, width: 40, height: 40)
                imageView.contentMode = .scaleAspectFill
            }
        }
        OperationQueue().addOperation(getCacheImage)
        view.addSubview(imageView)
        
        let nameLabel = UILabel()
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont(name: "TrebuchetMS-Bold", size: 18)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        nameLabel.frame = CGRect(x: 50, y: 4, width: frame.width - 80, height: 20)
        view.addSubview(nameLabel)
        
        let statusLabel = UILabel()
        
        if user.deactivated == "" {
            if user.onlineStatus == 1 {
                statusLabel.text = "онлайн"
                if user.onlineMobile == 1 {
                    statusLabel.text = "онлайн (моб.)"
                }
                statusLabel.textColor = UIColor.blue
            } else {
                if user.sex == 1 {
                    statusLabel.text = "заходила \(user.lastSeen.toStringLastTime())"
                } else {
                    statusLabel.text = "заходил \(user.lastSeen.toStringLastTime())"
                }
                statusLabel.textColor = UIColor.white
            }
        } else {
            if user.deactivated == "deleted" {
                statusLabel.text = "страница удалена"
            } else {
                statusLabel.text = "страница заблокирована"
            }
            statusLabel.textColor = UIColor.white
        }
        
        statusLabel.font = UIFont(name: "TrebuchetMS", size: 12)
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.5
        statusLabel.frame = CGRect(x: 50, y: 20, width: frame.width - 80, height: 20)
        view.addSubview(statusLabel)
        
        topItem?.titleView = view
    }
}
