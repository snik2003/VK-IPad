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
import Popover
import SCLAlertView

class MenuViewController: UITableViewController {

    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var notificationsCell: UITableViewCell!
    @IBOutlet weak var messagesCell: UITableViewCell!
    @IBOutlet weak var friendsCell: UITableViewCell!
    @IBOutlet weak var groupsCell: UITableViewCell!
    @IBOutlet weak var changeAccountCell: UITableViewCell!
    
    var navController: UINavigationController? {
        if let split = self.splitViewController {
            let detailVC = split.viewControllers[split.viewControllers.endIndex - 1]
            return detailVC.childViewControllers[0].navigationController
        }
        return nil
    }
    
    var accounts: [vkAccount] = []
    let userDefaults = UserDefaults.standard
    
    var changeAccount = false
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getLongPollServer()
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
            self.openNotificationController()
        }
        
        // Мои сообщения
        if indexPath.section == 0 && indexPath.row == 2 {
            self.openDialogsController()
        }
        
        // Новости
        if indexPath.section == 0 && indexPath.row == 3 {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewsfeedController") as! NewsfeedController
            
            if let split = self.splitViewController {
                let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
            }
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
            self.openPhotosListController(ownerID: vkSingleton.shared.userID, title: "Мои фотографии", type: "photos")
        }
        
        // Мои видеозаписи
        if indexPath.section == 1 && indexPath.row == 3 {
            self.openVideoListController(ownerID: vkSingleton.shared.userID, title: "Мои видеозаписи", type: "")
        }
        
        // Мои закладки
        if indexPath.section == 1 && indexPath.row == 4 {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "FavePostsController") as! FavePostsController
            
            if let split = self.splitViewController {
                let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
            }
        }
        
        // Мои подписки
        if indexPath.section == 1 && indexPath.row == 5 {
            self.openUsersController(uid: vkSingleton.shared.userID, title: "Мои отправленные заявки в друзья", type: "subscript")
        }
        
        // Моя музыка ITunes
        if indexPath.section == 1 && indexPath.row == 6 {
            
        }
        
        // настройки приложения
        if indexPath.section == 2 && indexPath.row == 0 {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "OptionsController") as! OptionsController
            
            if let split = self.splitViewController {
                let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                controller.width = detail.view.bounds.width
                detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
            }
        }
        
        // сменить учетную запись
        if indexPath.section == 2 && indexPath.row == 1 {
            self.showChangeAccountForm()
        }
        
        // написать разработчикам
        if indexPath.section == 2 && indexPath.row == 2 {
            self.openDialogController(ownerID: vkSingleton.shared.supportGroupID, startID: -1)
        }
        
        // выйти из учетной записи
        if indexPath.section == 2 && indexPath.row == 4 {
            self.exitAccountFunc()
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 1 && indexPath.row == 6 {
            return 0
        }
        
        if indexPath.section == 2 && indexPath.row == 3 {
            return 0
        }
        
        return 40
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
        
        code = "\(code) var d = API.groups.get({\"user_id\":\"\(vkSingleton.shared.userID)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"filter\":\"moder\",\"extended\":\"1\",\"fields\":\"id,name\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
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
            //print(json["response"][3]["items"])
            
            let userProfile = json["response"][4].compactMap { UserProfile(json: $0.1) }
            
            OperationQueue.main.addOperation {
                if userProfile.count > 0 {
                    let user = userProfile[0]
                    vkSingleton.shared.myProfile = user
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
            
            let notData = json["response"][1]["items"].compactMap { Notification(json: $0.1) }
            let groups = json["response"][2]["items"].compactMap { Groups(json: $0.1) }
            
            var countNewNots = groups.count
            let lastViewed = json["response"][1]["last_viewed"].intValue
            for not in notData {
                if not.date > lastViewed {
                    countNewNots += not.feedbackCount
                }
            }
            
            OperationQueue.main.addOperation {
                self.notificationsCell.setBadgeValue(value: countNewNots)
                self.groupsCell.setBadgeValue(value: groups.count)
            }
            
            vkSingleton.shared.adminGroups = json["response"][3]["items"].compactMap { GroupProfile(json: $0.1) }
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
    
    func readAccountsFromRealm() {
        do {
            var config = Realm.Configuration.defaultConfiguration
            config.deleteRealmIfMigrationNeeded = false
            
            let realm = try Realm(configuration: config)
            let accounts = realm.objects(vkAccount.self)
            
            self.accounts = Array(accounts)
        } catch {
            print(error)
        }
    }
    
    func showChangeAccountForm() {
        
        readAccountsFromRealm()
        
        let aView = ChangeAccountView()
        aView.delegate = self
        
        self.popover = Popover(options: self.popoverOptions)
        aView.popover = self.popover
        aView.configureView(accounts: accounts, addNewAccount: true)
        
        self.popover.show(aView, fromView: self.changeAccountCell)
    }
    
    func exitAccountFunc() {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleTop: 32.0,
            kWindowWidth: 350,
            kTitleFont: UIFont(name: "Verdana-Bold", size: 14)!,
            kTextFont: UIFont(name: "Verdana", size: 15)!,
            kButtonFont: UIFont(name: "Verdana", size: 16)!,
            showCloseButton: false,
            showCircularIcon: true
        )
        let alertView = SCLAlertView(appearance: appearance)
        
        alertView.addButton("Да, хочу выйти") {
            
            self.unregisterDeviceOnPush()
            vkUserLongPoll.shared.request.cancel()
            vkUserLongPoll.shared.firstLaunch = true
             
            /* for id in vkGroupLongPoll.shared.request.keys {
             if let request = vkGroupLongPoll.shared.request[id] {
             request.cancel()
             vkGroupLongPoll.shared.firstLaunch[id] = true
             vkSingleton.shared.groupToken[id] = nil
             }
             }*/
            
            self.performSegue(withIdentifier: "logoutVK", sender: nil)
        }
        
        alertView.addButton("Нет, я передумал") {}
        
        alertView.showWarning("Подтверждение!", subTitle: "Вы действительно хотите выйти из текущей учетной записи?")
    }
    
    func refreshUserInfo() {
        let url = "/method/users.get"
        let parameters = [
            "user_id": vkSingleton.shared.userID, //"357365563" 
            "access_token": vkSingleton.shared.accessToken,
            "fields": "id,first_name,last_name,maiden_name,domain,sex,relation,bdate,home_town,has_photo,city,country,status,last_seen,online,photo_max_orig,photo_max,photo_id,followers_count,counters,deactivated,education,contacts,connections,site,about,interests,activities,books,games,movies,music,tv,quotes,first_name_abl,first_name_gen,first_name_acc,can_post,can_send_friend_request,can_write_private_message,friend_status,is_favorite,blacklisted,blacklisted_by_me,crop_photo,is_hidden_from_feed,personal,relatives",
            "name_case": "nom",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let userProfile = json["response"].compactMap { UserProfile(json: $0.1) }
            
            if userProfile.count > 0 {
                OperationQueue.main.addOperation {
                    let user = userProfile[0]
                    self.navigationController?.navigationBar.setupUserProfileView(user: user)
                }
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
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
                imageView.layer.borderWidth = 1.4
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
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 15)
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
                statusLabel.textColor = vkSingleton.shared.onlineColor
                statusLabel.font = UIFont(name: "Verdana-Bold", size: 12)
            } else {
                if user.sex == 1 {
                    statusLabel.text = "заходила \(user.lastSeen.toStringLastTime())"
                } else {
                    statusLabel.text = "заходил \(user.lastSeen.toStringLastTime())"
                }
                statusLabel.textColor = UIColor.white
                statusLabel.font = UIFont(name: "Verdana", size: 11)
            }
        } else {
            if user.deactivated == "deleted" {
                statusLabel.text = "страница удалена"
            } else {
                statusLabel.text = "страница заблокирована"
            }
            statusLabel.textColor = UIColor.white
            statusLabel.font = UIFont(name: "Verdana", size: 11)
        }
        
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
