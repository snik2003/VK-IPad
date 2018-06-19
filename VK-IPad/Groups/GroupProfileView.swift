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
    
    let counterHeight: CGFloat = 60
    let counterInterSpacing: CGFloat = 20
    
    func configureView() -> CGFloat {
        
        var topY = setAvatarView()
        
        let infoView = UIView()
        infoView.backgroundColor = UIColor.white
        let width1 = 2 * delegate.tableView.bounds.width / 3 - 20
        
        let siteLabel = UILabel()
        if profile.site != "" {
            siteLabel.text = profile.site
        } else {
            siteLabel.text = "https://vk.com/\(profile.screenName)"
        }
        siteLabel.font = UIFont(name: "Verdana", size: 13)
        siteLabel.adjustsFontSizeToFitWidth = true
        siteLabel.minimumScaleFactor = 0.8
        siteLabel.textAlignment = .center
        siteLabel.prepareTextForPublish2(delegate)
        siteLabel.frame = CGRect(x: 10, y: 10, width: width1 - 20, height: 20)
        infoView.addSubview(siteLabel)
        
        infoView.frame = CGRect(x: 10, y: topY, width: width1, height: 40)
        self.addSubview(infoView)
        
        let membersView = UIView()
        membersView.backgroundColor = UIColor.white
        let width2 = delegate.tableView.bounds.width / 3 - 10
        
        let countButton = UIButton()
        if profile.type == "page" {
            countButton.setTitle(profile.membersCounter.subscribersAdder(), for: .normal)
        } else {
            countButton.setTitle(profile.membersCounter.membersAdder(), for: .normal)
        }
        countButton.setTitleColor(countButton.titleLabel?.tintColor, for: .normal)
        countButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)
        countButton.frame = CGRect(x: 10, y: 10, width: width2 - 20, height: 20)
        membersView.addSubview(countButton)
        
        countButton.add(for: .touchUpInside) {
            countButton.smallButtonTouched()
        }
        
        membersView.frame = CGRect(x: 2 * delegate.tableView.bounds.width / 3, y: topY, width: width2, height: 40)
        self.addSubview(membersView)
        topY += 40
        
        let number = getNumberOfCounters()
        if number > 0 {
            topY += 10
            let width3 = delegate.tableView.bounds.width - 20
            
            let insetsCounters = counterInterSpacing * CGFloat(number - 1)
            let totalCounterHeight = CGFloat(number) * counterHeight
            var leftX = (width3 - totalCounterHeight - insetsCounters) / 2
            
            let countersView = UIView()
            countersView.backgroundColor = UIColor.white
            
            if profile.photosCounter > 0 {
                let label1 = UILabel()
                label1.text = profile.photosCounter.getCounterToString()
                label1.textColor = label1.tintColor
                label1.textAlignment = .center
                label1.font = UIFont(name: "Verdana-Bold", size: 16)
                label1.adjustsFontSizeToFitWidth = true
                label1.minimumScaleFactor = 0.5
                label1.frame = CGRect(x: leftX, y: 10, width: counterHeight, height: counterHeight/2)
                countersView.addSubview(label1)
                
                let label2 = UILabel()
                label2.text = "фото"
                label2.isEnabled = false
                label2.textAlignment = .center
                label2.font = UIFont(name: "Verdana", size: 10)
                label2.adjustsFontSizeToFitWidth = true
                label2.minimumScaleFactor = 0.5
                label2.frame = CGRect(x: leftX, y: 10 + counterHeight/2, width: counterHeight, height: 20)
                countersView.addSubview(label2)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    
                }
                tap.numberOfTapsRequired = 1
                label1.isUserInteractionEnabled = true
                label1.addGestureRecognizer(tap)
                
                leftX += counterHeight + counterInterSpacing
            }
            
            if profile.albumsCounter > 0 {
                let label1 = UILabel()
                label1.text = profile.albumsCounter.getCounterToString()
                label1.textColor = label1.tintColor
                label1.textAlignment = .center
                label1.font = UIFont(name: "Verdana-Bold", size: 16)
                label1.adjustsFontSizeToFitWidth = true
                label1.minimumScaleFactor = 0.5
                label1.frame = CGRect(x: leftX, y: 10, width: counterHeight, height: counterHeight/2)
                countersView.addSubview(label1)
                
                let label2 = UILabel()
                label2.text = "альбомы"
                label2.isEnabled = false
                label2.textAlignment = .center
                label2.font = UIFont(name: "Verdana", size: 10)
                label2.adjustsFontSizeToFitWidth = true
                label2.minimumScaleFactor = 0.5
                label2.frame = CGRect(x: leftX, y: 10 + counterHeight/2, width: counterHeight, height: 20)
                countersView.addSubview(label2)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    
                }
                tap.numberOfTapsRequired = 1
                label1.isUserInteractionEnabled = true
                label1.addGestureRecognizer(tap)
                
                leftX += counterHeight + counterInterSpacing
            }
            
            if profile.videosCounter > 0 {
                let label1 = UILabel()
                label1.text = profile.videosCounter.getCounterToString()
                label1.textColor = label1.tintColor
                label1.textAlignment = .center
                label1.font = UIFont(name: "Verdana-Bold", size: 16)
                label1.adjustsFontSizeToFitWidth = true
                label1.minimumScaleFactor = 0.5
                label1.frame = CGRect(x: leftX, y: 10, width: counterHeight, height: counterHeight/2)
                countersView.addSubview(label1)
                
                let label2 = UILabel()
                label2.text = "видео"
                label2.isEnabled = false
                label2.textAlignment = .center
                label2.font = UIFont(name: "Verdana", size: 10)
                label2.adjustsFontSizeToFitWidth = true
                label2.minimumScaleFactor = 0.5
                label2.frame = CGRect(x: leftX, y: 10 + counterHeight/2, width: counterHeight, height: 20)
                countersView.addSubview(label2)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    
                }
                tap.numberOfTapsRequired = 1
                label1.isUserInteractionEnabled = true
                label1.addGestureRecognizer(tap)
                
                leftX += counterHeight + counterInterSpacing
            }
            
            if profile.topicsCounter > 0 {
                let label1 = UILabel()
                label1.text = profile.topicsCounter.getCounterToString()
                label1.textColor = label1.tintColor
                label1.textAlignment = .center
                label1.font = UIFont(name: "Verdana-Bold", size: 16)
                label1.adjustsFontSizeToFitWidth = true
                label1.minimumScaleFactor = 0.5
                label1.frame = CGRect(x: leftX, y: 10, width: counterHeight, height: counterHeight/2)
                countersView.addSubview(label1)
                
                let label2 = UILabel()
                label2.text = "обсуждения"
                label2.isEnabled = false
                label2.textAlignment = .center
                label2.font = UIFont(name: "Verdana", size: 10)
                label2.adjustsFontSizeToFitWidth = true
                label2.minimumScaleFactor = 0.5
                label2.frame = CGRect(x: leftX, y: 10 + counterHeight/2, width: counterHeight, height: 20)
                countersView.addSubview(label2)
                
                let tap = UITapGestureRecognizer()
                tap.add {
                    
                }
                tap.numberOfTapsRequired = 1
                label1.isUserInteractionEnabled = true
                label1.addGestureRecognizer(tap)
                
                leftX += counterHeight + counterInterSpacing
            }
            
            countersView.frame = CGRect(x: 10, y: topY, width: width3, height: 10 + counterHeight)
            self.addSubview(countersView)
            topY += 10 + counterHeight
        }
        
        return topY + 10
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
            var startY = (2 * leftInsets + avatarSize - size1.height - size2.height - 30) / 2
            if size2.height == 0 {
                startY = (2 * leftInsets + avatarSize - size1.height - size2.height - 20) / 2
            }
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
        if profile.isAdmin == 1 || profile.isMember == 1 {
            isMemberButton.setTitleColor(UIColor.black, for: .normal)
            isMemberButton.backgroundColor = vkSingleton.shared.backColor
        } else {
            isMemberButton.setTitleColor(UIColor.white, for: .normal)
            isMemberButton.backgroundColor = vkSingleton.shared.mainColor
        }
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
        if profile.isAdmin == 1 || profile.isMember == 1 {
            dopButton.setTitleColor(UIColor.black, for: .normal)
            dopButton.backgroundColor = vkSingleton.shared.backColor
        } else {
            dopButton.setTitleColor(UIColor.white, for: .normal)
            dopButton.backgroundColor = vkSingleton.shared.mainColor
        }
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
    
    func getNumberOfCounters() -> Int {
        var num = 0
        
        if let profile = self.profile {
            if profile.photosCounter > 0 {
                num += 1
            }
            
            if profile.albumsCounter > 0 {
                num += 1
            }
            
            if profile.videosCounter > 0 {
                num += 1
            }
            
            if profile.topicsCounter > 0 {
                num += 1
            }
        }
        
        return num
    }
}
