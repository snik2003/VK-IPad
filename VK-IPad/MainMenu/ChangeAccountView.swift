//
//  ChangeAccountView.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 23.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Popover

class ChangeAccountView: UIView {

    var delegate: UIViewController!
    var popover: Popover!
    
    let width: CGFloat = 290
    let avatarHeight: CGFloat = 50
    
    func configureView(accounts: [vkAccount], addNewAccount: Bool) {
        
        var topY: CGFloat = 10
        
        for account in accounts {
            
            let view = UIView()
            let avatarImage = UIImageView()
            let getCacheImage = GetCacheImage(url: account.avatarURL, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    avatarImage.image = getCacheImage.outputImage
                    avatarImage.layer.cornerRadius = self.avatarHeight/2
                    avatarImage.contentMode = .scaleAspectFill
                    avatarImage.clipsToBounds = true
                }
            }
            OperationQueue().addOperation(getCacheImage)
            
            avatarImage.frame = CGRect(x: 20, y: 10, width: avatarHeight, height: avatarHeight)
            view.addSubview(avatarImage)
            
            let nameLabel = UILabel()
            nameLabel.text = "\(account.firstName) \(account.lastName)"
            nameLabel.font = UIFont(name: "Verdana-Bold", size: 13)
            nameLabel.frame = CGRect(x: 20 + avatarHeight + 20, y: avatarImage.frame.midY - 20, width: width - 20 - avatarHeight - 20 - 20, height: 20)
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.5
            view.addSubview(nameLabel)
            
            let dateLabel = UILabel()
            if let userID = Int(vkSingleton.shared.userID), account.userID == userID {
                dateLabel.text = "текущая учетная запись"
                dateLabel.isEnabled = true
                dateLabel.textColor = UIColor.red
            } else {
                dateLabel.text = account.lastSeen.toStringLastTime()
                dateLabel.isEnabled = false
            }
            dateLabel.font = UIFont(name: "Verdana", size: 12)
            dateLabel.frame = CGRect(x: 20 + avatarHeight + 20, y: avatarImage.frame.midY, width: width - 20 - avatarHeight - 20 - 20, height: 16)
            view.addSubview(dateLabel)
            
            view.frame = CGRect(x: 0, y: topY, width: width, height: 10 + avatarHeight + 10)
            self.addSubview(view)
            
            topY += 10 + avatarHeight + 10
            self.setSeparator(topY: topY)
            
            let tap = UITapGestureRecognizer()
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(tap)
            tap.add {
                self.popover.dismiss()
                
                if let userID = Int(vkSingleton.shared.userID), account.userID != userID {
                    let alertController = UIAlertController(title: nil, message: "Вы действительно хотите перейти в  учетную запись «\(account.firstName) \(account.lastName)»?", preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                    alertController.addAction(cancelAction)
                    
                    let action = UIAlertAction(title: "Да, хочу", style: .default) { action in
                        
                        vkSingleton.shared.userID = "\(account.userID)"
                        vkSingleton.shared.avatarURL = ""
                        
                        UserDefaults.standard.set(vkSingleton.shared.userID, forKey: "vkUserID")
                        //self.readAppConfig()
                        
                        vkSingleton.shared.accessToken = self.delegate.getAccessTokenFromRealm(userID: Int(vkSingleton.shared.userID)!)
                        
                        /*vkUserLongPoll.shared.request.cancel()
                         vkUserLongPoll.shared.firstLaunch = true
                         
                         for id in vkGroupLongPoll.shared.request.keys {
                         if let request = vkGroupLongPoll.shared.request[id] {
                         request.cancel()
                         vkGroupLongPoll.shared.firstLaunch[id] = true
                         vkSingleton.shared.groupToken[id] = nil
                         }
                         }*/
                        
                        let controller = self.delegate.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                        //controller.changeAccount = true
                        
                        UIApplication.shared.keyWindow?.rootViewController = controller
                    }
                    alertController.addAction(action)
                    
                    self.delegate.present(alertController, animated: true)
                }
            }
        }
        
        if addNewAccount {
            let view = UIView()
            
            let avatarImage = UIImageView()
            avatarImage.image = UIImage(named: "add-account")
            avatarImage.contentMode = .scaleAspectFill
            avatarImage.clipsToBounds = true
            
            avatarImage.frame = CGRect(x: 20, y: 10, width: avatarHeight, height: avatarHeight)
            view.addSubview(avatarImage)
            
            let label = UILabel()
            label.text = "Новая учетная запись"
            label.font = UIFont(name: "Verdana-Bold", size: 12)
            label.contentMode = .center
            label.frame = CGRect(x: 20 + avatarHeight + 20, y: 0, width: width - 20 - avatarHeight - 20 - 20, height: 10 + avatarHeight + 10)
            view.addSubview(label)
            
            view.frame = CGRect(x: 0, y: topY, width: width, height: 10 + avatarHeight + 10)
            self.addSubview(view)
            
            topY += 10 + avatarHeight + 10
            
            let tap = UITapGestureRecognizer()
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(tap)
            tap.add {
                self.popover.dismiss()
                
                let alertController = UIAlertController(title: nil, message: "Вы действительно хотите добавить еще одну учетную запись?", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action = UIAlertAction(title: "Да, хочу", style: .destructive) { action in
                    vkSingleton.shared.avatarURL = ""
                    
                    /*vkUserLongPoll.shared.request.cancel()
                     vkUserLongPoll.shared.firstLaunch = true
                     
                     for id in vkGroupLongPoll.shared.request.keys {
                     if let request = vkGroupLongPoll.shared.request[id] {
                     request.cancel()
                     vkGroupLongPoll.shared.firstLaunch[id] = true
                     vkSingleton.shared.groupToken[id] = nil
                     }
                     }*/
                    
                    self.delegate.performSegue(withIdentifier: "addAccountVK", sender: nil)
                }
                alertController.addAction(action)
                
                self.delegate.present(alertController, animated: true)
            }
        }
        
        topY += 10
        self.frame = CGRect(x: 0, y: 0, width: width, height: topY)
    }

    func setSeparator(topY: CGFloat) {
        let separator = UIView()
        separator.frame = CGRect(x: 20 + avatarHeight + 20, y: topY, width: width - 60 - avatarHeight, height: 1)
        separator.backgroundColor = vkSingleton.shared.backColor
        separator.layer.borderWidth = 0.1
        separator.layer.borderColor = UIColor.gray.cgColor
        self.addSubview(separator)
    }
}