//
//  GroupProfileView.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 19.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class GroupProfileView: UIView {

    var delegate: GroupProfileViewController!
    var profile: GroupProfile!

    let dopButton = UIButton()
    let isMemberButton = UIButton()
    let usersMessageButton = UIButton()
    let ownerMessageButton = UIButton()
    
    let leftInsets: CGFloat = 10
    let avatarSize: CGFloat = 80
    let buttonHeight: CGFloat = 25
    
    func configureView() -> CGFloat {
        
        var topY = setAvatarView()
        
        return topY
    }
    
    func setAvatarView() -> CGFloat {
        
        var topY: CGFloat = 0
        
        let coverView = UIView()
        coverView.backgroundColor = UIColor.white
        
        let width = delegate.tableView.bounds.width - 20
        if profile.isCover == 1 {
            let coverHeight = width * CGFloat(profile.coverHeight) / CGFloat(profile.coverWidth)
            
            let coverImageView = UIImageView()
            
            let getCacheImage = GetCacheImage(url: profile.coverUrl, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    coverImageView.image = getCacheImage.outputImage
                    //coverImageView.layer.borderColor = UIColor.black.cgColor
                    //coverImageView.layer.borderWidth = 1.0
                    coverImageView.contentMode = .scaleAspectFit
                    coverImageView.clipsToBounds = true
                }
            }
            OperationQueue().addOperation(getCacheImage)
            
            coverImageView.frame = CGRect(x: 0, y: 0, width: width, height: coverHeight)
            coverView.addSubview(coverImageView)
            
            topY += coverHeight
        }
        
        let avatarImage = UIImageView()
        let getCacheImage = GetCacheImage(url: profile.photo100, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                avatarImage.image = getCacheImage.outputImage
                avatarImage.contentMode = .scaleAspectFill
                avatarImage.layer.cornerRadius = self.avatarSize/2
                avatarImage.clipsToBounds = true
            }
        }
        OperationQueue().addOperation(getCacheImage)
        avatarImage.frame = CGRect(x: leftInsets, y: topY + leftInsets, width: avatarSize, height: avatarSize)
        coverView.addSubview(avatarImage)
        
        let nameZoneWidth = width * 2 / 3 - 2 * leftInsets - avatarSize
        
        let nameLabel = UILabel()
        nameLabel.text = profile.name
        if profile.verified == 1 {
            nameLabel.text = "\(profile.name) ♻️"
        }
        nameLabel.font = UIFont(name: "Verdana-Bold", size: 15)!
        if profile.status == "" {
            nameLabel.font = UIFont(name: "Verdana-Bold", size: 17)!
        }
        nameLabel.numberOfLines = 0
        let size1 = delegate.getTextSize(text: nameLabel.text!, font: nameLabel.font, maxWidth: nameZoneWidth)
        nameLabel.frame = CGRect(x: 2 * leftInsets + avatarSize, y: topY, width: nameZoneWidth, height: size1.height + 10)
        coverView.addSubview(nameLabel)
        
        let typeLabel = UILabel()
        typeLabel.text = profile.groupType()
        typeLabel.font = UIFont(name: "Verdana", size: 12)!
        typeLabel.frame = CGRect(x: 2 * leftInsets + avatarSize, y: topY + size1.height + 10, width: nameZoneWidth, height: 16)
        typeLabel.isEnabled = false
        coverView.addSubview(typeLabel)
        
        let statusLabel = UILabel()
        statusLabel.text = profile.status
        statusLabel.prepareTextForPublish2(delegate)
        statusLabel.font = UIFont(name: "Verdana", size: 13)!
        statusLabel.numberOfLines = 0
        let size2 = delegate.getTextSize(text: statusLabel.text!, font: statusLabel.font, maxWidth: nameZoneWidth)
        statusLabel.frame = CGRect(x: 2 * leftInsets + avatarSize, y: topY + 10 + size1.height + 20, width: nameZoneWidth, height: size2.height)
        coverView.addSubview(statusLabel)
        
        var dopHeight: CGFloat = 0
        if 2 * leftInsets + avatarSize > 30 + size1.height + size2.height {
            let startY = (2 * leftInsets + avatarSize - size1.height - size2.height - 30) / 2
            nameLabel.frame = CGRect(x: 2 * leftInsets + avatarSize, y: topY + startY, width: nameZoneWidth, height: size1.height)
            typeLabel.frame = CGRect(x: 2 * leftInsets + avatarSize, y: topY + startY + size1.height, width: nameZoneWidth, height: 16)
            statusLabel.frame = CGRect(x: 2 * leftInsets + avatarSize, y: topY + startY + size1.height + 30, width: nameZoneWidth, height: size2.height)
            dopHeight += 2 * leftInsets + avatarSize
        } else {
            dopHeight += 30 + size1.height + size2.height
        }
        
        let startX = width * 2 / 3
        var startY = (dopHeight - buttonHeight) / 2
        if profile.canMessage == 1 {
            startY = (dopHeight - buttonHeight - 5 - buttonHeight) / 2
        }
        if profile.isAdmin == 1 {
            startY = (dopHeight - buttonHeight - 5 - buttonHeight - 5 - buttonHeight) / 2
        }
        
        isMemberButton.setTitle(profile.memberButtonText(), for: .normal)
        isMemberButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
        isMemberButton.setTitleColor(UIColor.white, for: .normal)
        isMemberButton.backgroundColor = vkSingleton.shared.mainColor
        isMemberButton.titleLabel?.textAlignment = NSTextAlignment.center
        isMemberButton.layer.borderColor = UIColor.lightGray.cgColor
        isMemberButton.layer.borderWidth = 0.6
        isMemberButton.layer.cornerRadius = 6
        isMemberButton.clipsToBounds = true
        
        isMemberButton.add(for: .touchUpInside) {
            self.isMemberButton.buttonTouched()
        }
        
        isMemberButton.frame = CGRect(x: startX + 10, y: topY + startY, width: width / 3 - 60, height: buttonHeight)
        coverView.addSubview(isMemberButton)
        
        dopButton.setTitle("●●●", for: .normal)
        dopButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
        dopButton.setTitleColor(UIColor.white, for: .normal)
        dopButton.backgroundColor = vkSingleton.shared.mainColor
        dopButton.titleLabel?.textAlignment = NSTextAlignment.center
        dopButton.layer.borderColor = UIColor.lightGray.cgColor
        dopButton.layer.borderWidth = 0.6
        dopButton.layer.cornerRadius = 6
        dopButton.clipsToBounds = true
        
        dopButton.add(for: .touchUpInside) {
            self.dopButton.buttonTouched()
        }
    
        dopButton.frame = CGRect(x: width - 45, y: topY + startY, width: buttonHeight + 10, height: buttonHeight)
        coverView.addSubview(dopButton)
        
        if profile.canMessage == 1 {
            usersMessageButton.setTitle("Написать сообщение", for: .normal)
            usersMessageButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
            usersMessageButton.setTitleColor(UIColor.white, for: .normal)
            usersMessageButton.backgroundColor = vkSingleton.shared.mainColor
            usersMessageButton.titleLabel?.textAlignment = NSTextAlignment.center
            usersMessageButton.layer.borderColor = UIColor.lightGray.cgColor
            usersMessageButton.layer.borderWidth = 0.6
            usersMessageButton.layer.cornerRadius = 6
            usersMessageButton.clipsToBounds = true
            
            usersMessageButton.add(for: .touchUpInside) {
                self.usersMessageButton.buttonTouched()
            }
            
            usersMessageButton.frame = CGRect(x: startX + 10, y: topY + startY + buttonHeight + 5, width: width / 3 - 20, height: buttonHeight)
            coverView.addSubview(usersMessageButton)
        }
        
        if profile.isAdmin == 1 {
            ownerMessageButton.setTitle("Сообщения сообщества", for: .normal)
            ownerMessageButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
            ownerMessageButton.setTitleColor(UIColor.white, for: .normal)
            ownerMessageButton.backgroundColor = vkSingleton.shared.mainColor
            ownerMessageButton.titleLabel?.textAlignment = NSTextAlignment.center
            ownerMessageButton.layer.borderColor = UIColor.lightGray.cgColor
            ownerMessageButton.layer.borderWidth = 0.6
            ownerMessageButton.layer.cornerRadius = 6
            ownerMessageButton.clipsToBounds = true
            
            ownerMessageButton.add(for: .touchUpInside) {
                self.ownerMessageButton.buttonTouched()
            }
            
            ownerMessageButton.frame = CGRect(x: startX + 10, y: topY + startY + buttonHeight + 5 + buttonHeight + 5, width: width / 3 - 20, height: buttonHeight)
            coverView.addSubview(ownerMessageButton)
        }
        
        topY += dopHeight
        coverView.frame = CGRect(x: 10, y: 10, width: width, height: topY)
        self.addSubview(coverView)
        
        return topY + 20
    }
}
