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

    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var notificationsCell: UITableViewCell!
    @IBOutlet weak var messagesCell: UITableViewCell!
    @IBOutlet weak var friendsCell: UITableViewCell!
    @IBOutlet weak var groupsCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Профиль
        if indexPath.section == 0 && indexPath.row == 0 {
            self.openProfileController(id: Int(vkSingleton.shared.userID)!, name: "")
        }
        
        // Ответы
        if indexPath.section == 0 && indexPath.row == 1 {
            
        }
        
        // Мои сообщения
        if indexPath.section == 0 && indexPath.row == 2 {
            
        }
        
        // Новости
        if indexPath.section == 0 && indexPath.row == 3 {
            
        }
        
        // Мои друзья
        if indexPath.section == 1 && indexPath.row == 0 {
            self.openUsersController(uid: vkSingleton.shared.userID, title: "Мои друзья", type: "friends")
        }
        
        // Мои сообщества
        if indexPath.section == 1 && indexPath.row == 1 {
            self.openGroupsListController(uid: vkSingleton.shared.userID, title: "Мои сообщества", type: "")
        }
        
        // Мои фотографии
        if indexPath.section == 1 && indexPath.row == 2 {
            
        }
        
        // Мои видеозаписи
        if indexPath.section == 1 && indexPath.row == 3 {
            
        }
        
        // Мои закладки
        if indexPath.section == 1 && indexPath.row == 4 {
            
        }
        
        // Мои подписки
        if indexPath.section == 1 && indexPath.row == 5 {
            self.openUsersController(uid: vkSingleton.shared.userID, title: "Мои отправленные заявки в друзья", type: "subscript")
        }
        
        // Моя музыка ITunes
        if indexPath.section == 1 && indexPath.row == 6 {
            
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
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
    
    func getUserInfo() {
        
        var code = "var f = API.users.get({\"user_id\":\"\(vkSingleton.shared.userID)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"fields\":\"id,first_name,last_name,domain,last_seen,online,photo_max_orig,photo_max,deactivated,sex\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var a = API.account.getCounters({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"filter\":\"friends,messages\",\"v\": \"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var b = API.notifications.get({\"count\":\"100\",\"start_time\":\"\(Date().timeIntervalSince1970 - 15552000)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"v\": \"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var c = API.groups.getInvites({\"count\":\"100\",\"extended\":\"1\",\"fields\":\"id,first_name,last_name,photo_100,sex\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var d = API.groups.get({\"user_id\":\"\(vkSingleton.shared.userID)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"filter\":\"moder\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var stat = API.stats.trackVisitor({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"v\":\"\(vkSingleton.shared.version)\"}); \n"
        
        code = "\(code) var e1 = API.groups.isMember({\"group_id\":\"166099539\",\"user_id\":\"\(vkSingleton.shared.userID)\"});\n"
        
        code = "\(code) if (e1 != 1) { var e2 = API.groups.join({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"group_id\":\"166099539\",\"v\": \"\(vkSingleton.shared.version)\"}); return [a,b,c,d,f,stat,e1,e2]; } \n"
        
        code = "\(code) return [a,b,c,d,f,stat,e1];"
        
        let url = "/method/execute"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "code": code,
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let userProfile = json["response"][4].compactMap { UserProfile(json: $0.1) }
            
            OperationQueue.main.addOperation {
                if userProfile.count > 0 {
                    let user = userProfile[0]
                    self.navigationController?.navigationBar.setupUserProfileView(user: user)
                    
                    if user.uid == vkSingleton.shared.userID {
                        self.saveAccountToRealm(user: user)
                    }
                }
            }
            
            let messages = json["response"][0]["messages"].intValue
            let friends = json["response"][0]["friends"].intValue
            
            OperationQueue.main.addOperation {
                self.messagesCell.setBadgeValue(value: messages)
                self.friendsCell.setBadgeValue(value: friends)
            }
            
            //let notData = json["response"][1]["items"].compactMap { Notifications(json: $0.1) }
            
            var countNewNots = 0
            /*let lastViewed = json["response"][1]["last_viewed"].intValue
            for not in notData {
                if not.date > lastViewed {
                    countNewNots += not.feedback.count
                }
            }
            
            let groups = json["response"][2]["items"].compactMap { Groups(json: $0.1) }*/
            
            OperationQueue.main.addOperation {
                self.notificationsCell.setBadgeValue(value: countNewNots)
                //self.groupsCell.setBadgeValue(value: groups.count)
            }
            
            let count = json["response"][3]["count"].intValue
            vkSingleton.shared.adminGroupID.removeAll(keepingCapacity: false)
            if count > 0 {
                for index in 0...count-1 {
                    let groupID = json["response"][3]["items"][index].intValue
                    vkSingleton.shared.adminGroupID.append(groupID)
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
        nameLabel.font = UIFont(name: "TrebuchetMS-Bold", size: 16)
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
        
        statusLabel.font = UIFont(name: "TrebuchetMS", size: 11)
        statusLabel.adjustsFontSizeToFitWidth = true
        statusLabel.minimumScaleFactor = 0.5
        statusLabel.frame = CGRect(x: 50, y: 20, width: frame.width - 80, height: 20)
        view.addSubview(statusLabel)
        
        topItem?.titleView = view
    }
}

extension UISplitViewController {
    func toggleMasterView() {
        if UIScreen.main.bounds.height > UIScreen.main.bounds.width {
            var nextDisplayMode: UISplitViewControllerDisplayMode
            switch(self.preferredDisplayMode){
            case .primaryHidden:
                nextDisplayMode = .allVisible
            default:
                nextDisplayMode = .primaryHidden
            }
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.preferredDisplayMode = nextDisplayMode
            }
        } else {
            // do nothing
        }
    }
}
