//
//  PhotoViewCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 20.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import ImageScrollView

class PhotoViewCell: UITableViewCell {


    @IBOutlet weak var imageScrollView: ImageScrollView!
    var delegate: PhotoViewController!
    
    var photo: Photo!
    
    var cellWidth: CGFloat = 0
    
    var likesButton = UIButton()
    var usersButton = UIButton()
    var commentsButton = UIButton()
    
    func configureLikesCell() {
        
        self.removeAllSubviews()
        let buttonWidth = (cellWidth - 20 - 50 - 50) / 3
        let buttonHeight = self.bounds.height
        
        likesButton.tag = 250
        likesButton.frame = CGRect(x: 10, y: 0, width: buttonWidth, height: buttonHeight)
        likesButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
        likesButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        likesButton.contentVerticalAlignment = .center
        
        setLikesButton()
        
        self.addSubview(likesButton)
        
        likesButton.add(for: .touchUpInside) {
            self.likesButton.smallButtonTouched()
            
            self.likesButton.isEnabled = false
            self.tapLikesButton()
        }
        
        usersButton.tag = 250
        usersButton.frame = CGRect(x: 10 + buttonWidth + 50, y: 0, width: buttonWidth, height: buttonHeight)
        usersButton.contentVerticalAlignment = .center
        usersButton.setImage(UIImage(named: "likes-list"), for: .normal)
        usersButton.imageView?.tintColor = UIColor.black
        
        self.addSubview(usersButton)
        
        commentsButton.tag = 250
        commentsButton.frame = CGRect(x: 10 + 2 * buttonWidth + 50 + 50, y: 0, width: buttonWidth, height: buttonHeight)
        commentsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
        commentsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        commentsButton.contentVerticalAlignment = .center
        
        commentsButton.setImage(UIImage(named: "comments"), for: .normal)
        commentsButton.setTitleColor(UIColor.init(red: 124/255, green: 172/255, blue: 238/255, alpha: 1), for: .normal)
        
        commentsButton.setTitle("\(photo.commentsCount)", for: UIControlState.normal)
        commentsButton.setTitle("\(photo.commentsCount)", for: UIControlState.selected)
        
        self.addSubview(commentsButton)
    }
    
    func setLikesButton() {
        likesButton.setTitle("\(photo.likesCount)", for: UIControlState.normal)
        likesButton.setTitle("\(photo.likesCount)", for: UIControlState.selected)
        
        if photo.userLikes == 1 {
            likesButton.setTitleColor(UIColor.purple, for: .normal)
            likesButton.setImage(UIImage(named: "like")?.tint(tintColor: UIColor.purple), for: .normal)
        } else {
            likesButton.setTitleColor(UIColor.darkGray, for: .normal)
            likesButton.setImage(UIImage(named: "like")?.tint(tintColor: UIColor.white), for: .normal)
            likesButton.imageView?.tintColor = UIColor.white
        }
    }
    
    func tapLikesButton() {
        if photo.userLikes == 0 {
            let url = "/method/likes.add"
            var parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "type": "photo",
                "owner_id": "\(photo.ownerID)",
                "item_id": "\(photo.id)",
                "v": vkSingleton.shared.version
            ]
            
            if photo.accessKey != "" {
                parameters["access_key"] = photo.accessKey
            }
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        self.photo.likesCount += 1
                        self.photo.userLikes = 1
                        self.setLikesButton()
                        self.likesButton.isEnabled = true
                    }
                } else {
                    OperationQueue.main.addOperation {
                        self.delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        self.likesButton.isEnabled = true
                    }
                }
            }
            OperationQueue().addOperation(request)
        } else {
            let url = "/method/likes.delete"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "type": "photo",
                "owner_id": "\(photo.ownerID)",
                "item_id": "\(photo.id)",
                "v": vkSingleton.shared.version
            ]
            
            let request = GetServerDataOperation(url: url, parameters: parameters)
            
            request.completionBlock = {
                guard let data = request.data else { return }
                
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let error = ErrorJson(json: JSON.null)
                error.errorCode = json["error"]["error_code"].intValue
                error.errorMsg = json["error"]["error_msg"].stringValue
                
                if error.errorCode == 0 {
                    OperationQueue.main.addOperation {
                        self.photo.likesCount -= 1
                        self.photo.userLikes = 0
                        self.setLikesButton()
                        self.likesButton.isEnabled = true
                    }
                } else {
                    OperationQueue.main.addOperation {
                        self.delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        self.likesButton.isEnabled = true
                    }
                }
            }
            OperationQueue().addOperation(request)
        }
    }
}
