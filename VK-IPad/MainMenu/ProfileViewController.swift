//
//  ProfileViewController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 13.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class ProfileViewController: UITableViewController {

    var userProfile: [UserProfile] = []
    
    var userID = vkSingleton.shared.userID
    
    var offset = 0
    let count = 20
    
    var isRefresh = false
    override func viewDidLoad() {
        super.viewDidLoad()

        //refreshExecute()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    func refreshExecute() {
        
        isRefresh = true
        
        var code = "var a = API.users.get({\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"user_id\":\"\(userID)\",\"fields\":\"id,first_name,last_name,maiden_name,domain,sex,relation,bdate,home_town,has_photo,city,country,status,last_seen,online,photo_max_orig,photo_max,photo_id,followers_count,counters,deactivated,education,contacts,connections,site,about,interests,activities,books,games,movies,music,tv,quotes,first_name_abl,first_name_gen,first_name_acc,can_post,can_send_friend_request,can_write_private_message,friend_status,is_favorite,blacklisted,blacklisted_by_me,crop_photo,is_hidden_from_feed,wall_default,personal,relatives\",\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        /*code = "\(code) var b = API.photos.getAll({\"owner_id\":\"\(userID)\",\"access_token\":\"\(vkSingleton.shared.accessToken)\",\"extended\":1,\"count\":100,\"photo_sizes\":0,\"skip_hidden\":0,\"v\": \"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var c = API.wall.get({\"owner_id\":\(userID),\"offset\":\(offset),\"access_token\": \"\(vkSingleton.shared.accessToken)\",\"count\":\(count),\"filter\":\"\(filterRecords)\",\"extended\":1,\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) var d = API.wall.get({\"owner_id\":\(userID),\"offset\":\(offset),\"access_token\": \"\(vkSingleton.shared.accessToken)\",\"count\":\(count),\"filter\":\"postponed\",\"extended\":1,\"v\":\"\(vkSingleton.shared.version)\"});\n"
        
        code = "\(code) return [a,b,c,d];"*/
        
        code = "\(code) return [a];"
        
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
            
            self.userProfile = json["response"][0].compactMap { UserProfile(json: $0.1) }
            //print(json["response"][0])
            
            if self.userProfile.count > 0 {
                let user = self.userProfile[0]
                if user.blacklisted == 1 {
                    self.showErrorMessage(title: "Предупреждение", msg: "\nВы находитесь в черном списке \(user.firstNameGen)\n")
                }
            }
            
            self.offset += self.count
            
            OperationQueue.main.addOperation {
                //self.setProfileView()
                self.tableView.reloadData()
                if self.userProfile.count > 0 {
                    let user = self.userProfile[0]
                    self.title = "\(user.firstName) \(user.lastName)"
                }
            }
            
            
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
}
