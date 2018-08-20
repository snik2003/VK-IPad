//
//  GroupProfileView.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 19.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import SCLAlertView

class GroupProfileView: UIView {

    var delegate: GroupProfileViewController!
    var profile: GroupProfile!

    let dopButton = UIButton()
    let isMemberButton = UIButton()
    
    let usersMessageButton = UIButton()
    let ownerMessageButton = UIButton()
    
    var allRecordsButton = UIButton()
    var ownerButton = UIButton()
    var othersButton = UIButton()
    var newRecordButton = UIButton()
    var postponedButton = UIButton()
    var recordsCountLabel = UILabel()
    
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
        siteLabel.prepareTextForPublish2(delegate, cell: nil)
        siteLabel.frame = CGRect(x: 10, y: 10, width: width1 - 20, height: 20)
        infoView.addSubview(siteLabel)
        var height1: CGFloat = 30
        
        if profile.activity != "" && (profile.type == "page" || profile.type == "event" ){
            let actLabel = UILabel()
            actLabel.text = "Тематика сообщества: \(profile.activity)"
            if profile.type == "event" {
                actLabel.text = "Дата события: \(profile.activity)"
            }
            actLabel.font = UIFont(name: "Verdana", size: 13)!
            actLabel.textAlignment = .center
            actLabel.numberOfLines = 0
            actLabel.isEnabled = false
            actLabel.prepareTextForPublish2(delegate, cell: nil)
            
            let size = delegate.getTextSize(text: actLabel.text!, font: actLabel.font, maxWidth: width1 - 20)
            actLabel.frame = CGRect(x: 10, y: height1, width: width1 - 20, height: size.height + 10)
            infoView.addSubview(actLabel)
            height1 += size.height + 10
        }
        
        if profile.description != "" {
            let descLabel = UILabel()
            descLabel.text = profile.description
            descLabel.font = UIFont(name: "Verdana", size: 13)!
            descLabel.numberOfLines = 0
            descLabel.prepareTextForPublish2(delegate, cell: nil)
            
            let size = delegate.getTextSize(text: descLabel.text!, font: descLabel.font, maxWidth: width1 - 20)
            descLabel.frame = CGRect(x: 10, y: height1, width: width1 - 20, height: size.height + 10)
            infoView.addSubview(descLabel)
            height1 += size.height + 10
        }
        
        infoView.frame = CGRect(x: 10, y: topY, width: width1, height: height1)
        self.addSubview(infoView)
        
        var height3: CGFloat = 0
        let countersView = UIView()
        let number = getNumberOfCounters()
        if number > 0 {
            let insetsCounters = counterInterSpacing * CGFloat(number - 1)
            let totalCounterHeight = CGFloat(number) * counterHeight
            var leftX = (width1 - totalCounterHeight - insetsCounters) / 2
            
            countersView.backgroundColor = UIColor.white
            
            if profile.photosCounter > 0 {
                let label1 = UILabel()
                label1.text = profile.photosCounter.getCounterToString()
                //label1.textColor = label1.tintColor
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
                    self.delegate.openPhotosListController(ownerID: "-\(self.profile.gid)", title: "Фотографии cообщества \"\(self.profile.name)\"", type: "photos")
                }
                tap.numberOfTapsRequired = 1
                label1.isUserInteractionEnabled = true
                label1.addGestureRecognizer(tap)
                
                leftX += counterHeight + counterInterSpacing
            }
            
            if profile.albumsCounter > 0 {
                let label1 = UILabel()
                label1.text = profile.albumsCounter.getCounterToString()
                //label1.textColor = label1.tintColor
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
                    self.delegate.openPhotosListController(ownerID: "-\(self.profile.gid)", title: "Фотографии cообщества «\(self.profile.name)»", type: "albums")
                }
                tap.numberOfTapsRequired = 1
                label1.isUserInteractionEnabled = true
                label1.addGestureRecognizer(tap)
                
                leftX += counterHeight + counterInterSpacing
            }
            
            if profile.videosCounter > 0 {
                let label1 = UILabel()
                label1.text = profile.videosCounter.getCounterToString()
                //label1.textColor = label1.tintColor
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
                    var title = "Видеозаписи сообщества «\(self.profile.name)»"
                    
                    if self.profile.name.length > 30 {
                        title = "Видеозаписи сообщества «\(self.profile.name.prefix(30))...»"
                    }
                    
                    self.delegate.openVideoListController(ownerID: "-\(self.delegate.groupID)", title: title, type: "")
                }
                tap.numberOfTapsRequired = 1
                label1.isUserInteractionEnabled = true
                label1.addGestureRecognizer(tap)
                
                leftX += counterHeight + counterInterSpacing
            }
            
            if profile.topicsCounter > 0 {
                let label1 = UILabel()
                label1.text = profile.topicsCounter.getCounterToString()
                //label1.textColor = label1.tintColor
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
                    let controller = self.delegate.storyboard?.instantiateViewController(withIdentifier: "TopicsListController") as! TopicsListController
                    
                    controller.groupID = "\(self.profile.gid)"
                    controller.group = self.profile
                    controller.title = "Обсуждения в сообществе «\(self.profile.name)»"
                    
                    if let split = self.delegate.splitViewController {
                        let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                        controller.width = detail.view.bounds.width
                        detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
                    }
                }
                tap.numberOfTapsRequired = 1
                label1.isUserInteractionEnabled = true
                label1.addGestureRecognizer(tap)
                
                leftX += counterHeight + counterInterSpacing
            }
            
            countersView.frame = CGRect(x: 10, y: topY + height1 + 10, width: width1, height: 10 + counterHeight)
            self.addSubview(countersView)
            
            height3 += 10 + counterHeight
        } else {
            height3 = -10
        }
        
        
        let width2 = delegate.tableView.bounds.width / 3 - 10
        let leftX = 2 * delegate.tableView.bounds.width / 3
        
        var height2: CGFloat = 40
        if profile.membersCounter > 0 {
            let size = (width2 - 10 - 15) / 4
            height2 += size + 5
            if profile.membersCounter > 4 {
                height2 += size + 5
            }
            if profile.membersCounter > 8 {
                height2 += size + 5
            }
            if profile.membersCounter > 12 {
                height2 += size + 5
            }
            height2 += 5
        }
        
        getMembersView(width: width2, leftX: leftX, topY: topY, maxHeight: height2)
        
        if height2 > height1 + height3 + 10 {
            infoView.frame = CGRect(x: 10, y: topY, width: width1, height: height2 - height3 - 10)
            if height3 > 0 {
                countersView.frame = CGRect(x: 10, y: topY + height2 - height3, width: width1, height: height3)
            }
        }
        
        topY += max(height1 + 10 + height3, height2)
        
        if profile.deactivated == "" {
            topY += 10
            
            let ownersButtonsView = UIView()
            ownersButtonsView.backgroundColor = UIColor.white
            let width = delegate.tableView.frame.width - 20
            ownersButtonsView.frame = CGRect(x: 10, y: topY, width: width, height: 10 + buttonHeight)
            
            setOwnerButton(view: ownersButtonsView, topY: topY)
            
            self.addSubview(ownersButtonsView)
            topY += buttonHeight + 10
        }
        
        if profile.deactivated == "" {
            topY += 10
            
            let recordsButtonsView = UIView()
            recordsButtonsView.backgroundColor = UIColor.white
            let width = delegate.tableView.frame.width - 20
            recordsButtonsView.frame = CGRect(x: 10, y: topY, width: width, height: 10 + buttonHeight)
            
            setRecordsButton(view: recordsButtonsView, topY: topY)
            
            self.addSubview(recordsButtonsView)
            topY += buttonHeight + 10
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
        statusLabel.prepareTextForPublish2(delegate, cell: nil)
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
        
        if profile.deactivated == "" {
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
                
                self.joinGroup()
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
                
                self.tapDopButton()
            }
        
            dopButton.frame = CGRect(x: width - 45, y: topY + startY, width: buttonHeight + 10, height: buttonHeight)
            coverView.addSubview(dopButton)
        }
        
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
    
    func tapDopButton() {
        if let profile = self.profile {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            if profile.contacts.count > 0 {
                let action1 = UIAlertAction(title: "Контакты сообщества", style: .default) { action in
                    
                    profile.showContactsView(delegate: self.delegate, startView: self.dopButton)
                }
                alertController.addAction(action1)
            }
            
            if profile.isAdmin == 1 {
                let action1 = UIAlertAction(title: "Новая тема в «Обсуждения»", style: .default) { action in
                    
                    
                }
                alertController.addAction(action1)
            }
            
            let action2 = UIAlertAction(title: "Скопировать ссылку", style: .default) { action in
                
                var link = "https://vk.com/\(profile.screenName)"
                if profile.screenName == "" {
                    link = "https://vk.com/club\(profile.gid)"
                    if profile.type == "page" {
                        link = "https://vk.com/public\(profile.gid)"
                    } else if profile.type == "event" {
                        link = "https://vk.com/event\(profile.gid)"
                    }
                }
                
                UIPasteboard.general.string = link
                if let string = UIPasteboard.general.string {
                    self.delegate.showInfoMessage(title: "Ссылка на профиль сообщества:", msg: "\(string)")
                }
            }
            alertController.addAction(action2)
            
            
            var title = ""
            var style: UIAlertActionStyle = .default
            
            if profile.isFavorite == 1 {
                title = "Удалить из «Избранное»"
                style = .destructive
            } else {
                title = "Добавить в «Избранное»"
                style = .default
            }
            
            let action3 = UIAlertAction(title: title, style: style) { action in
                
                self.delegate.groupInFave()
            }
            alertController.addAction(action3)
            
            
            if profile.isHiddenFromFeed == 0 {
                title = "Скрывать новости в ленте"
                style = .destructive
            } else {
                title = "Показывать новости в ленте"
                style = .default
            }
            
            let action4 = UIAlertAction(title: title, style: style) { action in
                
                self.delegate.groupInNewsfeed()
            }
            alertController.addAction(action4)
            
            
            let userDefaults = UserDefaults.standard
            if profile.isAdmin == 1 {
                if let _ = userDefaults.string(forKey: "\(vkSingleton.shared.userID)_groupToken_\(profile.gid)") {
                    let action5 = UIAlertAction(title: "Забыть токен сообщества", style: .destructive) { action in
                        
                        userDefaults.removeObject(forKey: "\(vkSingleton.shared.userID)_groupToken_\(profile.gid)")
                        vkSingleton.shared.groupToken[profile.gid] = nil
                        
                        /*if let request = vkGroupLongPoll.shared.request[profile.gid] {
                            request.cancel()
                            vkGroupLongPoll.shared.firstLaunch[profile.gid] = true
                        }*/
                    }
                    alertController.addAction(action5)
                }
            }
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.dopButton
                let bounds = self.dopButton.bounds
                popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.maxY + 10, width: 0, height: 0)
                popoverController.permittedArrowDirections = [.up]
            }
            
            self.delegate.present(alertController, animated: true)
        }
    }
    
    func joinGroup() {
        if profile.isAdmin == 1 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action1 = UIAlertAction(title: "Пригласить друзей", style: .default) { action in
                
                let сontroller = self.delegate.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
                
                сontroller.userID = vkSingleton.shared.userID
                сontroller.type = "friends"
                сontroller.source = "invite"
                сontroller.title = "Пригласить друзей"
                
                сontroller.navigationItem.hidesBackButton = true
                let cancelButton = UIBarButtonItem(title: "Закрыть", style: .plain, target: сontroller, action: #selector(сontroller.tapCancelButton(sender:)))
                сontroller.navigationItem.leftBarButtonItem = cancelButton
                сontroller.delegate = self.delegate
                
                if let split = self.delegate.splitViewController {
                    let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                    detail.childViewControllers[0].navigationController?.pushViewController(сontroller, animated: true)
                }
            }
            alertController.addAction(action1)
            
            let action2 = UIAlertAction(title: "Покинуть сообщество", style: .destructive) { action in
                
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleTop: 32.0,
                    kWindowWidth: 400,
                    kTitleFont: UIFont(name: "Verdana-Bold", size: 14)!,
                    kTextFont: UIFont(name: "Verdana", size: 15)!,
                    kButtonFont: UIFont(name: "Verdana", size: 16)!,
                    showCloseButton: false,
                    showCircularIcon: true
                )
                let alertView = SCLAlertView(appearance: appearance)
                
                alertView.addButton("Да, хочу покинуть сообщество") {
                    
                    self.leaveGroup()
                }
                
                alertView.addButton("Нет, я передумал") {}
                
                alertView.showWarning("Подтверждение!", subTitle: "Внимание! Вы являетесь администратором данного сообщества.\n\nВы действительно хотите покинуть сообщество «\(self.profile.name)»?")
            }
            alertController.addAction(action2)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = self.isMemberButton
                popoverController.sourceRect = CGRect(x: self.isMemberButton.bounds.midX, y: self.isMemberButton.bounds.maxY + 10, width: 0, height: 0)
                popoverController.permittedArrowDirections = [.up]
            }
            
            self.delegate.present(alertController, animated: true)
        } else {
            if profile.isMember == 0 {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                if profile.type != "event" {
                    let OKAction = UIAlertAction(title: profile.memberButtonText(), style: .default) { action in
                        
                        let url = "/method/groups.join"
                        
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "group_id": "\(self.profile.gid)",
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
                                self.profile.isMember = 1
                                self.profile.membersCounter += 1
                                OperationQueue.main.addOperation {
                                    self.isMemberButton.setTitle(self.profile.memberButtonText(), for: .normal)
                                    self.isMemberButton.setTitleColor(UIColor.black, for: .normal)
                                    self.isMemberButton.backgroundColor = vkSingleton.shared.backColor
                                    
                                    self.dopButton.setTitleColor(UIColor.black, for: .normal)
                                    self.dopButton.backgroundColor = vkSingleton.shared.backColor
                                }
                            } else {
                                self.delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                            }
                        }
                        
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(OKAction)
                } else {
                    let action1 = UIAlertAction(title: "Да, я приму участие", style: .default) { action in
                        let url = "/method/groups.join"
                        
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "group_id": "\(self.profile.gid)",
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
                                self.profile.isMember = 1
                                self.profile.membersCounter += 1
                                OperationQueue.main.addOperation {
                                    self.isMemberButton.setTitle(self.profile.memberButtonText(), for: .normal)
                                    self.isMemberButton.setTitleColor(UIColor.black, for: .normal)
                                    self.isMemberButton.backgroundColor = vkSingleton.shared.backColor
                                    
                                    self.dopButton.setTitleColor(UIColor.black, for: .normal)
                                    self.dopButton.backgroundColor = vkSingleton.shared.backColor
                                    
                                    self.delegate.updateAppCounters()
                                }
                            } else {
                                self.delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                            }
                        }
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action1)
                    
                    let action2 = UIAlertAction(title: "Возможно, я приму участие", style: .destructive) { action in
                        let url = "/method/groups.join"
                        
                        let parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "group_id": "\(self.profile.gid)",
                            "not_sure": "1",
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
                                self.profile.isMember = 1
                                self.profile.membersCounter += 1
                                OperationQueue.main.addOperation {
                                    self.isMemberButton.setTitle(self.profile.memberButtonText(), for: .normal)
                                    self.isMemberButton.setTitleColor(UIColor.black, for: .normal)
                                    self.isMemberButton.backgroundColor = vkSingleton.shared.backColor
                                    
                                    self.dopButton.setTitleColor(UIColor.black, for: .normal)
                                    self.dopButton.backgroundColor = vkSingleton.shared.backColor
                                    
                                    self.delegate.updateAppCounters()
                                }
                            } else {
                                self.delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                            }
                        }
                        OperationQueue().addOperation(request)
                    }
                    alertController.addAction(action2)
                    
                    let action3 = UIAlertAction(title: "Отклонить приглашение", style: .destructive) { action in
                        
                        self.leaveGroup()
                    }
                    alertController.addAction(action3)
                }
                    
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.isMemberButton
                    popoverController.sourceRect = CGRect(x: self.isMemberButton.bounds.midX, y: self.isMemberButton.bounds.maxY + 10, width: 0, height: 0)
                    popoverController.permittedArrowDirections = [.up]
                }
                
                self.delegate.present(alertController, animated: true)
            } else if profile.isMember == 1 {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let OKAction = UIAlertAction(title: "Отписаться", style: .destructive) { action in
                    
                    self.leaveGroup()
                }
                alertController.addAction(OKAction)
                
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.isMemberButton
                    popoverController.sourceRect = CGRect(x: self.isMemberButton.bounds.midX, y: self.isMemberButton.bounds.maxY + 10, width: 0, height: 0)
                    popoverController.permittedArrowDirections = [.up]
                }
                
                self.delegate.present(alertController, animated: true)
            }
        }
    }
    
    func getMembersView(width: CGFloat, leftX: CGFloat, topY: CGFloat, maxHeight: CGFloat) {
        
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        view.frame = CGRect(x: leftX, y: topY, width: width, height: maxHeight)
        self.addSubview(view)
        
        let countButton = UIButton()
        if profile.type == "page" {
            countButton.setTitle(profile.membersCounter.subscribersAdder(), for: .normal)
        } else {
            countButton.setTitle(profile.membersCounter.membersAdder(), for: .normal)
        }
        countButton.setTitleColor(countButton.titleLabel?.tintColor, for: .normal)
        countButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)
        countButton.frame = CGRect(x: 10, y: 10, width: width - 20, height: 20)
        view.addSubview(countButton)
        
        countButton.add(for: .touchUpInside) {
            countButton.smallButtonTouched()
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
            
            let action1 = UIAlertAction(title: "Все участники", style: .default) { action in
                let usersController = self.delegate.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
                
                usersController.userID = "\(self.profile.gid)"
                usersController.type = "members"
                usersController.filters = ""
                usersController.title = "Все участники сообщества «\(self.profile.name)»"
                if self.profile.name.length > 30 {
                    usersController.title = "Все участники сообщества «\(self.profile.name.prefix(30))...»"
                }
                
                let detailVC = self.delegate.splitViewController!.viewControllers[self.delegate.splitViewController!.viewControllers.endIndex - 1]
                detailVC.childViewControllers[0].navigationController?.pushViewController(usersController, animated: true)
            }
            alertController.addAction(action1)
            
            let action2 = UIAlertAction(title: "Только друзья", style: .default) { action in
                let usersController = self.delegate.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
                
                usersController.userID = "\(self.profile.gid)"
                usersController.type = "members"
                usersController.filters = "friends"
                usersController.title = "Ваши друзья в сообществе «\(self.profile.name)»"
                if self.profile.name.length > 30 {
                    usersController.title = "Ваши друзья в сообществе «\(self.profile.name.prefix(30))...»"
                }
                
                let detailVC = self.delegate.splitViewController!.viewControllers[self.delegate.splitViewController!.viewControllers.endIndex - 1]
                detailVC.childViewControllers[0].navigationController?.pushViewController(usersController, animated: true)
            }
            alertController.addAction(action2)
            
            if self.profile.isAdmin == 1 {
                let action3 = UIAlertAction(title: "Руководители сообщества", style: .default) { action in
                    let usersController = self.delegate.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
                    
                    usersController.userID = "\(self.profile.gid)"
                    usersController.type = "members"
                    usersController.filters = "managers"
                    usersController.title = "Руководители сообщества «\(self.profile.name)»"
                    if self.profile.name.length > 30 {
                        usersController.title = "Руководители сообщества «\(self.profile.name.prefix(30))...»"
                    }
                    
                    let detailVC = self.delegate.splitViewController!.viewControllers[self.delegate.splitViewController!.viewControllers.endIndex - 1]
                    detailVC.childViewControllers[0].navigationController?.pushViewController(usersController, animated: true)
                }
                alertController.addAction(action3)
            }
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = countButton
                popoverController.sourceRect = CGRect(x: countButton.bounds.minX, y: countButton.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = [.right]
            }
            
            self.delegate.present(alertController, animated: true)
        }
        
        var height: CGFloat = 40
        
        let url = "/method/groups.getMembers"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(profile.gid)",
            "count": "30",
            "fields": "photo_100, first_name",
            "v": vkSingleton.shared.version
        ]
        
        let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
        getServerDataOperation.completionBlock = {
            guard let data = getServerDataOperation.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            //print(json)
            
            let users = json["response"]["items"].compactMap({ UserProfile(json: $0.1) })
            
            OperationQueue.main.addOperation {
                if users.count > 0 {
                
                    var num = 4
                    if users.count < num {
                        num = users.count
                    }
                    let faceSize = (width - 5 - 5 - 15) / 4
                
                    for index1 in 1...4 {
                        let start = 4 * (index1 - 1)
                        let finish = min(4 * index1 - 1,users.count-1)
                        
                        if users.count > start {
                            var x1 = (width - CGFloat(num) * faceSize - CGFloat(num - 1) * 5) / 2
                            
                            for index2 in start...finish {
                                let faceImage = UIImageView()
                                
                                let getCacheImage = GetCacheImage(url: users[index2].photo100, lifeTime: .avatarImage)
                                getCacheImage.completionBlock = {
                                    OperationQueue.main.addOperation {
                                        faceImage.image = getCacheImage.outputImage
                                        faceImage.layer.cornerRadius = faceSize / 2
                                        faceImage.contentMode = .scaleAspectFill
                                        faceImage.clipsToBounds = true
                                    }
                                }
                                OperationQueue().addOperation(getCacheImage)
                                
                                let tap = UITapGestureRecognizer()
                                faceImage.isUserInteractionEnabled = true
                                faceImage.addGestureRecognizer(tap)
                                tap.add {
                                    if let id = Int(users[index2].uid) {
                                        self.delegate.openProfileController(id: id, name: "\(users[index2].firstName) \(users[index2].lastName)")
                                    }
                                }
                                faceImage.frame = CGRect(x: x1, y: height, width: faceSize, height: faceSize)
                                view.addSubview(faceImage)
                                
                                x1 += faceSize + 5
                            }
                            height += faceSize + 5
                        }
                    }
                    
                    height += 5
                }
            }
        }
        OperationQueue().addOperation(getServerDataOperation)
    }
    
    func updateOwnerButtons() {
        if allRecordsButton.isSelected {
            allRecordsButton.setTitleColor(UIColor.white, for: .selected)
            allRecordsButton.layer.borderColor = UIColor.black.cgColor
            allRecordsButton.layer.cornerRadius = 5
            allRecordsButton.clipsToBounds = true
            allRecordsButton.backgroundColor = vkSingleton.shared.mainColor
            allRecordsButton.tintColor = vkSingleton.shared.mainColor
            
            ownerButton.isSelected = false
            ownerButton.setTitleColor(UIColor.black, for: .normal)
            ownerButton.clipsToBounds = true
            ownerButton.backgroundColor = UIColor.lightGray
            ownerButton.tintColor = UIColor.lightGray
            ownerButton.layer.cornerRadius = 5
            
            othersButton.isSelected = false
            othersButton.setTitleColor(UIColor.black, for: .normal)
            othersButton.clipsToBounds = true
            othersButton.backgroundColor = UIColor.lightGray
            othersButton.tintColor = UIColor.lightGray
            othersButton.layer.cornerRadius = 5
            
            postponedButton.isSelected = false
            postponedButton.setTitleColor(UIColor.black, for: .normal)
            postponedButton.clipsToBounds = true
            postponedButton.backgroundColor = UIColor.lightGray
            postponedButton.tintColor = UIColor.lightGray
            postponedButton.layer.cornerRadius = 5
        }
        
        if ownerButton.isSelected {
            ownerButton.setTitleColor(UIColor.white, for: .selected)
            ownerButton.layer.borderColor = UIColor.black.cgColor
            ownerButton.clipsToBounds = true
            ownerButton.backgroundColor = vkSingleton.shared.mainColor
            ownerButton.tintColor = vkSingleton.shared.mainColor
            ownerButton.layer.cornerRadius = 5
            
            allRecordsButton.isSelected = false
            allRecordsButton.setTitleColor(UIColor.black, for: .normal)
            allRecordsButton.clipsToBounds = true
            allRecordsButton.backgroundColor = UIColor.lightGray
            allRecordsButton.tintColor = UIColor.lightGray
            allRecordsButton.layer.cornerRadius = 5
            
            othersButton.isSelected = false
            othersButton.setTitleColor(UIColor.black, for: .normal)
            othersButton.clipsToBounds = true
            othersButton.backgroundColor = UIColor.lightGray
            othersButton.tintColor = UIColor.lightGray
            othersButton.layer.cornerRadius = 5
            
            postponedButton.isSelected = false
            postponedButton.setTitleColor(UIColor.black, for: .normal)
            postponedButton.clipsToBounds = true
            postponedButton.backgroundColor = UIColor.lightGray
            postponedButton.tintColor = UIColor.lightGray
            postponedButton.layer.cornerRadius = 5
        }
        
        if othersButton.isSelected {
            othersButton.setTitleColor(UIColor.white, for: .selected)
            othersButton.layer.borderColor = UIColor.black.cgColor
            othersButton.clipsToBounds = true
            othersButton.backgroundColor = vkSingleton.shared.mainColor
            othersButton.tintColor = vkSingleton.shared.mainColor
            othersButton.layer.cornerRadius = 5
            
            allRecordsButton.isSelected = false
            allRecordsButton.setTitleColor(UIColor.black, for: .normal)
            allRecordsButton.clipsToBounds = true
            allRecordsButton.backgroundColor = UIColor.lightGray
            allRecordsButton.tintColor = UIColor.lightGray
            allRecordsButton.layer.cornerRadius = 5
            
            ownerButton.isSelected = false
            ownerButton.setTitleColor(UIColor.black, for: .normal)
            ownerButton.clipsToBounds = true
            ownerButton.backgroundColor = UIColor.lightGray
            ownerButton.tintColor = UIColor.lightGray
            ownerButton.layer.cornerRadius = 5
            
            postponedButton.isSelected = false
            postponedButton.setTitleColor(UIColor.black, for: .normal)
            postponedButton.clipsToBounds = true
            postponedButton.backgroundColor = UIColor.lightGray
            postponedButton.tintColor = UIColor.lightGray
            postponedButton.layer.cornerRadius = 5
        }
        
        if postponedButton.isSelected {
            postponedButton.setTitleColor(UIColor.white, for: .selected)
            postponedButton.layer.borderColor = UIColor.black.cgColor
            postponedButton.clipsToBounds = true
            postponedButton.backgroundColor = vkSingleton.shared.mainColor
            postponedButton.tintColor = vkSingleton.shared.mainColor
            postponedButton.layer.cornerRadius = 5
            
            allRecordsButton.isSelected = false
            allRecordsButton.setTitleColor(UIColor.black, for: .normal)
            allRecordsButton.clipsToBounds = true
            allRecordsButton.backgroundColor = UIColor.lightGray
            allRecordsButton.tintColor = UIColor.lightGray
            allRecordsButton.layer.cornerRadius = 5
            
            ownerButton.isSelected = false
            ownerButton.setTitleColor(UIColor.black, for: .normal)
            ownerButton.clipsToBounds = true
            ownerButton.backgroundColor = UIColor.lightGray
            ownerButton.tintColor = UIColor.lightGray
            ownerButton.layer.cornerRadius = 5
            
            othersButton.isSelected = false
            othersButton.setTitleColor(UIColor.black, for: .normal)
            othersButton.clipsToBounds = true
            othersButton.backgroundColor = UIColor.lightGray
            othersButton.tintColor = UIColor.lightGray
            othersButton.layer.cornerRadius = 5
        }
    }
    
    func setOwnerButton(view: UIView, topY: CGFloat) {
        
        allRecordsButton.setTitle("Все записи", for: .normal)
        allRecordsButton.setTitle("Все записи", for: .selected)
        allRecordsButton.titleLabel?.font = UIFont(name: "Verdana", size: 12)!
        allRecordsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        allRecordsButton.titleLabel?.minimumScaleFactor = 0.5
        
        allRecordsButton.frame = CGRect(x: view.bounds.width / 2 - 80, y: 5, width: 160, height: buttonHeight)
        
        ownerButton.setTitle("Записи сообщества", for: .selected)
        ownerButton.setTitle("Записи сообщества", for: .normal)
        ownerButton.titleLabel?.font = UIFont(name: "Verdana", size: 12)!
        ownerButton.titleLabel?.adjustsFontSizeToFitWidth = true
        ownerButton.titleLabel?.minimumScaleFactor = 0.5
        
        ownerButton.frame = CGRect(x: 4 * view.bounds.width / 5 - 80, y: 5, width: 160, height: buttonHeight)
        
        othersButton.setTitle("Чужие записи", for: .normal)
        othersButton.setTitle("Чужие записи", for: .selected)
        othersButton.titleLabel?.font = UIFont(name: "Verdana", size: 12)!
        othersButton.titleLabel?.adjustsFontSizeToFitWidth = true
        othersButton.titleLabel?.minimumScaleFactor = 0.5
        
        othersButton.frame = CGRect(x: view.bounds.width / 5 - 80, y: 5, width: 160, height: buttonHeight)
        
        if delegate.filterRecords == "owner" {
            allRecordsButton.isSelected = false
            ownerButton.isSelected = true
            othersButton.isSelected = false
            postponedButton.isSelected = false
        } else if delegate.filterRecords == "others" {
            allRecordsButton.isSelected = false
            ownerButton.isSelected = false
            othersButton.isSelected = true
            postponedButton.isSelected = false
        } else if delegate.filterRecords == "postponed" {
            allRecordsButton.isSelected = false
            ownerButton.isSelected = false
            othersButton.isSelected = false
            postponedButton.isSelected = true
        } else {
            allRecordsButton.isSelected = true
            ownerButton.isSelected = false
            othersButton.isSelected = false
            postponedButton.isSelected = false
        }
        
        updateOwnerButtons()
        
        allRecordsButton.add(for: .touchUpInside) {
            self.allRecordsButton.buttonTouched()
            self.delegate.offset = 0
            
            self.allRecordsButton.isSelected = true
            self.ownerButton.isSelected = false
            self.othersButton.isSelected = false
            self.postponedButton.isSelected = false
            
            self.delegate.refreshWall(filter: "all")
        }
        
        ownerButton.add(for: .touchUpInside) {
            self.ownerButton.buttonTouched()
            self.delegate.offset = 0
            
            self.allRecordsButton.isSelected = false
            self.ownerButton.isSelected = true
            self.othersButton.isSelected = false
            self.postponedButton.isSelected = false
            
            self.delegate.refreshWall(filter: "owner")
        }
        
        othersButton.add(for: .touchUpInside) {
            self.othersButton.buttonTouched()
            self.delegate.offset = 0
            
            self.allRecordsButton.isSelected = false
            self.ownerButton.isSelected = false
            self.othersButton.isSelected = true
            self.postponedButton.isSelected = false
            
            self.delegate.refreshWall(filter: "others")
        }
        
        view.addSubview(allRecordsButton)
        view.addSubview(ownerButton)
        view.addSubview(othersButton)
        
    }
    
    func setRecordsButton(view: UIView, topY: CGFloat) {
        
        if (profile.canPost == 1) {
            newRecordButton.setTitle("Новая запись", for: .normal)
            newRecordButton.setTitleColor(newRecordButton.tintColor, for: .normal)
            newRecordButton.setTitleColor(UIColor.black, for: .highlighted)
            newRecordButton.setTitleColor(UIColor.black, for: .selected)
            newRecordButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
            newRecordButton.contentHorizontalAlignment = .left
            newRecordButton.contentMode = .center
            
            newRecordButton.add(for: .touchUpInside) {
                self.newRecordButton.buttonTouched()
                
                let title = "Опубликовать новую запись в сообществе"
                self.delegate.openNewRecordController(ownerID: "-\(self.profile.gid)", mode: .new, title: title)
            }
            
            newRecordButton.frame = CGRect(x: 10, y: 5, width: 150, height: buttonHeight)
            view.addSubview(newRecordButton)
        } else if profile.type == "page" {
            newRecordButton.setTitle("Предложить новость", for: .normal)
            newRecordButton.setTitleColor(newRecordButton.tintColor, for: .normal)
            newRecordButton.setTitleColor(UIColor.black, for: .highlighted)
            newRecordButton.setTitleColor(UIColor.black, for: .selected)
            newRecordButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
            newRecordButton.contentHorizontalAlignment = .left
            newRecordButton.contentMode = .center
            
            newRecordButton.add(for: .touchUpInside) {
                self.newRecordButton.buttonTouched()
                
                let title = "Предложить новость в сообщество"
                self.delegate.openNewRecordController(ownerID: "-\(self.profile.gid)", mode: .new, title: title)
            }
            
            newRecordButton.frame = CGRect(x: 10, y: 5, width: 150, height: buttonHeight)
            view.addSubview(newRecordButton)
        }
        
        
        
        if profile.type == "group" && delegate.postponedWall.count > 0 {
            postponedButton.setTitle("Отложенные записи (\(delegate.postponedWall.count))", for: .normal)
            postponedButton.setTitle("Отложенные записи (\(delegate.postponedWall.count))", for: .selected)
            
            postponedButton.titleLabel?.font = UIFont(name: "Verdana", size: 12)!
            postponedButton.titleLabel?.adjustsFontSizeToFitWidth = true
            postponedButton.titleLabel?.minimumScaleFactor = 0.6
            
            postponedButton.isSelected = false
            postponedButton.setTitleColor(UIColor.black, for: .normal)
            postponedButton.clipsToBounds = true
            postponedButton.backgroundColor = UIColor.lightGray
            postponedButton.tintColor = UIColor.lightGray
            postponedButton.layer.cornerRadius = 5
            
            postponedButton.add(for: .touchUpInside) {
                self.postponedButton.buttonTouched()
                self.delegate.offset = 0
                
                self.allRecordsButton.isSelected = false
                self.ownerButton.isSelected = false
                self.othersButton.isSelected = false
                self.postponedButton.isSelected = true
                
                self.delegate.refreshWall(filter: "postponed")
            }
            postponedButton.frame = CGRect(x: view.bounds.width / 2 - 100, y: 5, width: 200, height: buttonHeight)
            view.addSubview(postponedButton)
        }
        
        if profile.type == "page" && delegate.suggestedWall.count > 0 {
            postponedButton.setTitle("Предложенные записи (\(delegate.suggestedWall.count))", for: .normal)
            postponedButton.setTitle("Предложенные записи (\(delegate.suggestedWall.count))", for: .selected)
            
            postponedButton.titleLabel?.font = UIFont(name: "Verdana", size: 12)!
            postponedButton.titleLabel?.adjustsFontSizeToFitWidth = true
            postponedButton.titleLabel?.minimumScaleFactor = 0.6
            
            postponedButton.isSelected = false
            postponedButton.setTitleColor(UIColor.black, for: .normal)
            postponedButton.clipsToBounds = true
            postponedButton.backgroundColor = UIColor.lightGray
            postponedButton.tintColor = UIColor.lightGray
            postponedButton.layer.cornerRadius = 5
            
            postponedButton.add(for: .touchUpInside) {
                self.postponedButton.buttonTouched()
                self.delegate.offset = 0
                
                self.allRecordsButton.isSelected = false
                self.ownerButton.isSelected = false
                self.othersButton.isSelected = false
                self.postponedButton.isSelected = true
                
                self.delegate.refreshWall(filter: "suggests")
            }
            postponedButton.frame = CGRect(x: view.bounds.width / 2 - 100, y: 5, width: 200, height: buttonHeight)
            view.addSubview(postponedButton)
        }
        
        recordsCountLabel.text = "Всего записей: \(delegate.recordsCount)"
        recordsCountLabel.textAlignment = .right
        recordsCountLabel.textColor = recordsCountLabel.tintColor
        recordsCountLabel.font = UIFont(name: "Verdana", size: 13)!
        
        recordsCountLabel.frame = CGRect(x: view.bounds.width - 10 - 150, y: 5, width: 150, height: buttonHeight)
        view.addSubview(recordsCountLabel)
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
    
    func leaveGroup() {
        let url = "/method/groups.leave"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "group_id": "\(self.profile.gid)",
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
                self.profile.isMember = 0
                self.profile.isAdmin = 0
                self.profile.membersCounter -= 1
                
                OperationQueue.main.addOperation {
                    self.isMemberButton.setTitle(self.profile.memberButtonText(), for: .normal)
                    self.isMemberButton.setTitleColor(UIColor.white, for: .normal)
                    self.isMemberButton.backgroundColor = vkSingleton.shared.mainColor
                    
                    self.dopButton.setTitleColor(UIColor.white, for: .normal)
                    self.dopButton.backgroundColor = vkSingleton.shared.mainColor
                }
            } else {
                self.delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
}
