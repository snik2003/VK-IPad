//
//  LikesUsersController.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 21.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class LikesUsersController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var likes = [Likes]()
    var reposts = [Likes]()
    var users = [Likes]()
    
    var mode: Int = 0
    
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        segmentedControl.selectedSegmentIndex = 0
        for like in likes {
            users.append(like)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl)
    {
        users.removeAll(keepingCapacity: false)
        switch sender.selectedSegmentIndex {
        case 0:
            self.title = "Оценили"
            for like in likes {
                users.append(like)
            }
        case 1:
            self.title = "Поделились"
            for repost in reposts {
                users.append(repost)
            }
        case 2:
            self.title = "Оценили друзья"
            for like in likes {
                if like.friendStatus == 3 {
                    users.append(like)
                }
            }
        default:
            break
        }
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView()
        
        viewHeader.backgroundColor = .white
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        
        viewFooter.backgroundColor = .white
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        
        let user = users[indexPath.row]
        
        if user.maxPhotoURL != "" {
            let getCacheImage = GetCacheImage(url: user.maxPhotoURL, lifeTime: .userWallImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: cell.imageView!, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            queue.addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                cell.imageView?.layer.cornerRadius = 20
                cell.imageView?.clipsToBounds = true
            }
        }
        
        cell.textLabel?.attributedText = nil
        cell.textLabel?.text = "\(user.firstName) \(user.lastName) "
        if user.onlineStatus == 1 {
            if user.onlineMobile == 1 {
                let fullString = "\(user.firstName) \(user.lastName) "
                cell.textLabel?.setOnlineMobileStatus(text: "\(fullString)", platform: user.platform)
            } else {
                let fullString = "\(user.firstName) \(user.lastName) ●"
                let rangeOfColoredString = (fullString as NSString).range(of: "●")
                let attributedString = NSMutableAttributedString(string: fullString)
                
                if let color = cell.textLabel?.tintColor {
                    attributedString.setAttributes([NSAttributedStringKey.foregroundColor:  color], range: rangeOfColoredString)
                }
                cell.textLabel?.attributedText = attributedString
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        if let id = Int(user.uid) {
            
            var title = ""
            if id > 0 {
                title = "\(user.firstName) \(user.lastName)"
            } else {
                let name = user.firstName
                if name.length > 20 {
                    title = "\((name).prefix(20))..."
                } else {
                    title = name
                }
            }
            
            if user.type == "profile" {
                self.openProfileController(id: id, name: title)
            } else {
                self.openProfileController(id: -1 * id, name: title)
            }
        }
    }
}
