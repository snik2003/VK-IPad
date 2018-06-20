//
//  PhotoViewCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 20.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class PhotoViewCell: UITableViewCell {

    @IBOutlet weak var photoImage: UIImageView!
    
    var photo: Photo!
    var cellWidth: CGFloat = 0
    
    var likesButton = UIButton()
    var usersButton = UIButton()
    var commentsButton = UIButton()
    
    func configureLikesCell() {
        
        self.removeAllSubviews()
        let buttonWidth = (cellWidth - 20 - 40 - 40) / 3
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
        }
        
        usersButton.tag = 250
        usersButton.frame = CGRect(x: 10 + buttonWidth + 40, y: 0, width: buttonWidth, height: buttonHeight)
        usersButton.contentVerticalAlignment = .center
        usersButton.setImage(UIImage(named: "likes-list"), for: .normal)
        usersButton.imageView?.tintColor = UIColor.black
        
        self.addSubview(usersButton)
        
        usersButton.add(for: .touchUpInside) {
            self.usersButton.smallButtonTouched()
        }
        
        commentsButton.tag = 250
        commentsButton.frame = CGRect(x: 10 + 2 * buttonWidth + 40 + 40, y: 0, width: buttonWidth, height: buttonHeight)
        commentsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
        commentsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        commentsButton.contentVerticalAlignment = .center
        
        commentsButton.setImage(UIImage(named: "comments"), for: .normal)
        commentsButton.setTitleColor(UIColor.init(red: 124/255, green: 172/255, blue: 238/255, alpha: 1), for: .normal)
        
        commentsButton.setTitle("\(photo.commentsCount)", for: UIControlState.normal)
        commentsButton.setTitle("\(photo.commentsCount)", for: UIControlState.selected)
        
        self.addSubview(commentsButton)
        
        commentsButton.add(for: .touchUpInside) {
            self.commentsButton.smallButtonTouched()
        }
    }
    
    func setLikesButton() {
        likesButton.setTitle("\(photo.likesCount)", for: UIControlState.normal)
        likesButton.setTitle("\(photo.likesCount)", for: UIControlState.selected)
        
        if photo.userLikes == 1 {
            likesButton.setTitleColor(UIColor.purple, for: .normal)
            likesButton.setImage(UIImage(named: "like")?.tint(tintColor:  UIColor.purple), for: .normal)
        } else {
            likesButton.setTitleColor(UIColor.darkGray, for: .normal)
            likesButton.setImage(UIImage(named: "like")?.tint(tintColor:  UIColor.white), for: .normal)
        }
    }
}
