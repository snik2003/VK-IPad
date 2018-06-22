//
//  ProfileView.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 14.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class ProfileView: UIView {

    var delegate: ProfileViewController!
    var user: UserProfile!
    var photos: [Photo] = []
    
    var avatarImage = UIImageView()
    var userInfoView = UIView()
    var messageButton = UIButton()
    var friendButton = UIButton()
    var additionalButton = UIButton()
    var allRecordsButton = UIButton()
    var ownerButton = UIButton()
    var othersButton = UIButton()
    var newRecordButton = UIButton()
    var postponedButton = UIButton()
    var recordsCountLabel = UILabel()
    let lastLabel = UILabel()
    
    var avatarHeight: CGFloat = 20
    let buttonHeight: CGFloat = 25
    
    var counterHeight: CGFloat = 60
    let counterInterSpacing: CGFloat = 20
    
    func configureView(more: Bool) -> CGFloat {
    
        var topY: CGFloat = 0
        
        if let profile = user {
            avatarHeight = delegate.tableView.bounds.width * 0.3
            var avatarViewHeight = avatarHeight + 30 + 10 + 3 * buttonHeight
            if delegate.userID == vkSingleton.shared.userID {
                avatarViewHeight = avatarHeight + 30 + buttonHeight
            }
            if profile.deactivated != "" {
                avatarViewHeight = avatarHeight + 20
            }
            
            let avatarView = UIView()
            avatarView.backgroundColor = UIColor.white
            avatarView.frame = CGRect(x: 10, y: 10, width: avatarHeight + 20, height: avatarViewHeight)
            
            setAvatarImage()
            avatarView.addSubview(avatarImage)
            self.addSubview(avatarView)
            
            if profile.deactivated == "" {
                if delegate.userID != vkSingleton.shared.userID {
                    messageButton.layer.borderColor = UIColor.lightGray.cgColor
                    messageButton.layer.borderWidth = 0.6
                    messageButton.layer.cornerRadius = 5
                    messageButton.clipsToBounds = true
                    messageButton.setTitle("Написать сообщение", for: .normal)
                    
                    messageButton.add(for: .touchUpInside) {
                        self.messageButton.buttonTouched()
                    }
                    
                    friendButton.titleLabel?.textAlignment = .center
                    friendButton.layer.borderColor = UIColor.lightGray.cgColor
                    friendButton.layer.borderWidth = 0.6
                    friendButton.layer.cornerRadius = 5
                    friendButton.clipsToBounds = true
                    
                    friendButton.add(for: .touchUpInside) {
                        self.friendButton.buttonTouched()
                    }
                    
                    if profile.canWritePrivateMessage == 1 {
                        messageButton.isEnabled = true
                        messageButton.backgroundColor = vkSingleton.shared.mainColor
                    } else {
                        messageButton.isEnabled = false
                        messageButton.backgroundColor = UIColor.lightGray
                    }
                    
                    updateFriendButton()
                    
                    messageButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
                    friendButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
                    
                    
                    friendButton.frame = CGRect(x: 10, y: avatarImage.frame.maxY+10, width: avatarHeight, height: buttonHeight)
                    messageButton.frame = CGRect(x: 10, y: friendButton.frame.maxY+5, width: avatarHeight, height: buttonHeight)
                    
                    avatarView.addSubview(friendButton)
                    avatarView.addSubview(messageButton)
                }
                
                additionalButton.layer.borderColor = UIColor.lightGray.cgColor
                additionalButton.layer.borderWidth = 0.6
                additionalButton.layer.cornerRadius = 5
                additionalButton.clipsToBounds = true
                additionalButton.setTitle("Дополнительные функции", for: .normal)
                additionalButton.backgroundColor = vkSingleton.shared.mainColor
                additionalButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
                
                additionalButton.add(for: .touchUpInside) {
                    self.additionalButton.buttonTouched()
                }
                
                if delegate.userID == vkSingleton.shared.userID {
                    additionalButton.frame = CGRect(x: 10, y: avatarImage.frame.maxY+10, width: avatarHeight, height: buttonHeight)
                } else {
                    additionalButton.frame = CGRect(x: 10, y: messageButton.frame.maxY+5, width: avatarHeight, height: buttonHeight)
                }
                
                avatarView.addSubview(additionalButton)
            }
            
            userInfoView.backgroundColor = UIColor.white
            userInfoView.frame = CGRect(x: avatarView.frame.maxX + 10, y: 10, width: delegate.tableView.frame.width - 30 - avatarView.frame.width, height: 0)
            let userInfoViewHeight = setUserInfoView()
            self.addSubview(userInfoView)
            
            topY = avatarViewHeight
            if userInfoViewHeight > avatarViewHeight {
                topY = userInfoViewHeight
                userInfoView.frame = CGRect(x: avatarView.frame.maxX + 10, y: 10, width: delegate.tableView.frame.width - 30 - avatarView.frame.width, height: userInfoViewHeight)
            } else {
                userInfoView.frame = CGRect(x: avatarView.frame.maxX + 10, y: 10, width: delegate.tableView.frame.width - 30 - avatarView.frame.width, height: avatarViewHeight)
            }
            
            if profile.deactivated == "" && photos.count > 0 {
                topY += 20
                
                let photosView = UIView()
                photosView.backgroundColor = UIColor.white
                let width = delegate.tableView.frame.width - 20
                let photoHeight: CGFloat = (width - 10 * 4 - 2 * 10) / 5
                
                let label1 = UILabel()
                if delegate.userID == vkSingleton.shared.userID {
                    label1.text = "Мои фотографии "
                } else {
                    label1.text = "Фотографии \(profile.firstNameGen) "
                }
                label1.textColor = label1.tintColor
                label1.font = UIFont(name: "Verdana", size: 13)
                let size1 = delegate.getTextSize(text: label1.text!, font: label1.font!, maxWidth: width)
                label1.frame = CGRect(x: 10, y: 10, width: size1.width, height: 20)
                photosView.addSubview(label1)
                
                let label2 = UILabel()
                label2.text = "\(profile.photosCount)"
                label2.textColor = label1.tintColor
                label2.font = UIFont(name: "Verdana", size: 13)
                label2.isEnabled = false
                label2.frame = CGRect(x: 10 + size1.width, y: 10, width: width - 20 - size1.width, height: 20)
                photosView.addSubview(label2)
                
                var leftX: CGFloat = 10
                for index in 0...min(4, photos.count-1) {
                    let photo = UIImageView()
                    
                    let getCacheImage = GetCacheImage(url: photos[index].photo604, lifeTime: .avatarImage)
                    getCacheImage.completionBlock = {
                        OperationQueue.main.addOperation {
                            photo.image = getCacheImage.outputImage
                            photo.contentMode = .scaleAspectFill
                            photo.layer.borderColor = UIColor.lightGray.cgColor
                            photo.layer.borderWidth = 0.6
                            photo.clipsToBounds = true
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                    photo.frame = CGRect(x: leftX, y: 40, width: photoHeight, height: photoHeight)
                    photosView.addSubview(photo)
                    leftX += photoHeight + 10
                    
                    let tap = UITapGestureRecognizer()
                    photo.isUserInteractionEnabled = true
                    photo.addGestureRecognizer(tap)
                    tap.add {
                        self.delegate.openPhotoViewController(numPhoto: index, photos: self.photos)
                    }
                }
                
                photosView.frame = CGRect(x: 10, y: topY, width: width, height: photoHeight + 50)
                self.addSubview(photosView)
                topY += photoHeight + 50
            }
            
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
            
            if profile.deactivated == "" /*&& (profile.canPost == 1 || self.delegate.postponedWall.count > 0)*/ {
                topY += 10
                
                let recordsButtonsView = UIView()
                recordsButtonsView.backgroundColor = UIColor.white
                let width = delegate.tableView.frame.width - 20
                recordsButtonsView.frame = CGRect(x: 10, y: topY, width: width, height: 10 + buttonHeight)
                
                setRecordsButton(view: recordsButtonsView, topY: topY)
                
                self.addSubview(recordsButtonsView)
                topY += buttonHeight + 10
            }
        }
        
        return topY + 10
    }
    
    func setUserInfoView() -> CGFloat {
        
        var topY: CGFloat = 0
        
        if let profile = user {
            let nameLabel = UILabel()
            nameLabel.text = "\(profile.firstName) \(profile.lastName)"
            nameLabel.frame = CGRect(x: 20, y: 10, width: userInfoView.frame.width * 0.5 - 30, height: 30)
            nameLabel.font = UIFont(name: "Verdana-Bold", size: 18)
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.5
            userInfoView.addSubview(nameLabel)
            
            
            if profile.deactivated == "" {
                if profile.onlineStatus == 1 {
                    lastLabel.text = " онлайн"
                    lastLabel.textColor = UIColor.blue
                    lastLabel.isEnabled = true
                } else {
                    if profile.sex == 1 {
                        lastLabel.text = " заходила \(profile.lastSeen.toStringLastTime())"
                        
                    } else {
                        lastLabel.text = " заходил \(profile.lastSeen.toStringLastTime())"
                    }
                    lastLabel.isEnabled = false
                }
            } else {
                if profile.deactivated == "deleted" {
                    lastLabel.text = " Страница удалена"
                } else {
                    lastLabel.text = " Страница заблокирована"
                }
                lastLabel.isEnabled = false
            }
            
            if profile.platform > 0 && profile.platform != 7 {
                lastLabel.setPlatformStatus(text: "\(lastLabel.text!)", platform: profile.platform, online: profile.onlineStatus)
            }
            
            lastLabel.textAlignment = .right
            lastLabel.frame = CGRect(x: userInfoView.frame.width * 0.5 + 10, y: 10, width: userInfoView.frame.width * 0.5 - 30, height: 30)
            lastLabel.font = UIFont(name: "Verdana", size: 12)
            lastLabel.adjustsFontSizeToFitWidth = true
            lastLabel.minimumScaleFactor = 0.5
            userInfoView.addSubview(lastLabel)
            topY = 10 + 30 + 5
            
            if profile.deactivated == "" {
                let statusLabel = UILabel()
                statusLabel.text = profile.status
                statusLabel.numberOfLines = 0
                statusLabel.font = UIFont(name: "Verdana", size: 13)
                let size = delegate.getTextSize(text: statusLabel.text!, font: statusLabel.font!, maxWidth: userInfoView.frame.width - 40)
                statusLabel.frame = CGRect(x: 20, y: topY, width: size.width, height: size.height)
                userInfoView.addSubview(statusLabel)
                topY += size.height + 9
                
                setSeparator(inView: userInfoView, topY: topY)
                topY += 1
                
                if profile.birthDate != "" {
                
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale?
                    dateFormatter.dateFormat = "dd.M.yyyy"
                    var date = dateFormatter.date(from: user.birthDate)
                    dateFormatter.dateFormat = "dd MMMM yyyy года"
                    if date == nil {
                        dateFormatter.dateFormat = "dd.M"
                        date = dateFormatter.date(from: user.birthDate)
                        dateFormatter.dateFormat = "dd MMMM"
                    }
                    
                    let label1 = UILabel()
                    label1.text = "День рождения:"
                    label1.font = UIFont(name: "Verdana", size: 13)
                    label1.adjustsFontSizeToFitWidth = true
                    label1.minimumScaleFactor = 0.5
                    label1.isEnabled = false
                    label1.frame = CGRect(x: 20, y: topY + 10, width: userInfoView.frame.width * 0.4 - 20, height: 20)
                    userInfoView.addSubview(label1)
                    
                    let label2 = UILabel()
                    label2.text = dateFormatter.string(from: date!)
                    label2.font = UIFont(name: "Verdana", size: 13)
                    label2.adjustsFontSizeToFitWidth = true
                    label2.minimumScaleFactor = 0.5
                    label2.frame = CGRect(x: userInfoView.frame.width * 0.4, y: topY + 10, width: userInfoView.frame.width * 0.6 - 20, height: 20)
                    userInfoView.addSubview(label2)
                    
                    topY += 30
                }
                
                if profile.countryName != "" {
                    let label1 = UILabel()
                    label1.text = "Страна:"
                    label1.font = UIFont(name: "Verdana", size: 13)
                    label1.adjustsFontSizeToFitWidth = true
                    label1.minimumScaleFactor = 0.5
                    label1.isEnabled = false
                    label1.frame = CGRect(x: 20, y: topY + 10, width: userInfoView.frame.width * 0.4 - 20, height: 20)
                    userInfoView.addSubview(label1)
                    
                    let label2 = UILabel()
                    label2.text = profile.countryName
                    label2.font = UIFont(name: "Verdana", size: 13)
                    label2.adjustsFontSizeToFitWidth = true
                    label2.minimumScaleFactor = 0.5
                    label2.frame = CGRect(x: userInfoView.frame.width * 0.4, y: topY + 10, width: userInfoView.frame.width * 0.6 - 20, height: 20)
                    userInfoView.addSubview(label2)
                    
                    topY += 30
                }
                
                if profile.cityName != "" {
                    let label1 = UILabel()
                    label1.text = "Город:"
                    label1.font = UIFont(name: "Verdana", size: 13)
                    label1.adjustsFontSizeToFitWidth = true
                    label1.minimumScaleFactor = 0.5
                    label1.isEnabled = false
                    label1.frame = CGRect(x: 20, y: topY + 10, width: userInfoView.frame.width * 0.4 - 20, height: 20)
                    userInfoView.addSubview(label1)
                    
                    let label2 = UILabel()
                    label2.text = profile.cityName
                    label2.font = UIFont(name: "Verdana", size: 13)
                    label2.adjustsFontSizeToFitWidth = true
                    label2.minimumScaleFactor = 0.5
                    label2.frame = CGRect(x: userInfoView.frame.width * 0.4, y: topY + 10, width: userInfoView.frame.width * 0.6 - 20, height: 20)
                    userInfoView.addSubview(label2)
                    
                    topY += 30
                }
                
                if profile.relation != 0 {
                    let label1 = UILabel()
                    label1.text = "Семейное положение:"
                    label1.font = UIFont(name: "Verdana", size: 13)
                    label1.adjustsFontSizeToFitWidth = true
                    label1.minimumScaleFactor = 0.5
                    label1.isEnabled = false
                    label1.frame = CGRect(x: 20, y: topY + 10, width: userInfoView.frame.width * 0.4 - 20, height: 20)
                    userInfoView.addSubview(label1)
                    
                    let label2 = UILabel()
                    label2.text = profile.relation.relationCodeIntoString(sex: profile.sex)
                    label2.font = UIFont(name: "Verdana", size: 13)
                    label2.adjustsFontSizeToFitWidth = true
                    label2.minimumScaleFactor = 0.5
                    label2.frame = CGRect(x: userInfoView.frame.width * 0.4, y: topY + 10, width: userInfoView.frame.width * 0.6 - 20, height: 20)
                    userInfoView.addSubview(label2)
                    
                    topY += 30
                }
                
                if profile.site != "" {
                    let label1 = UILabel()
                    label1.text = "Веб-сайт:"
                    label1.font = UIFont(name: "Verdana", size: 13)
                    label1.adjustsFontSizeToFitWidth = true
                    label1.minimumScaleFactor = 0.5
                    label1.isEnabled = false
                    label1.frame = CGRect(x: 20, y: topY + 10, width: userInfoView.frame.width * 0.4 - 20, height: 20)
                    userInfoView.addSubview(label1)
                    
                    let label2 = UILabel()
                    label2.text = profile.site
                    label2.textColor = label2.tintColor
                    label2.font = UIFont(name: "Verdana", size: 13)
                    label2.adjustsFontSizeToFitWidth = true
                    label2.minimumScaleFactor = 0.5
                    label2.frame = CGRect(x: userInfoView.frame.width * 0.4, y: topY + 10, width: userInfoView.frame.width * 0.6 - 20, height: 20)
                    userInfoView.addSubview(label2)
                    
                    topY += 30
                }
                
                let moreInfoButton = UIButton()
                moreInfoButton.setTitle("Посмотреть подробную информацию", for: .normal)
                moreInfoButton.setTitleColor(moreInfoButton.titleLabel?.tintColor, for: .normal)
                moreInfoButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)
                moreInfoButton.frame = CGRect(x: 40, y: topY + 10, width: userInfoView.frame.width - 80, height: 30)
                userInfoView.addSubview(moreInfoButton)
                
                topY += 40
                
                let number = getNumberOfCounters()
                if number > 0 {
                    setSeparator(inView: userInfoView, topY: topY + 9)
                    topY += 10 + 10
                    
                    var insetsCounters = counterInterSpacing * CGFloat(number - 1)
                    var totalCounterHeight = CGFloat(number) * counterHeight
                    var leftX = (userInfoView.frame.width - totalCounterHeight - insetsCounters) / 2
                    
                    if leftX < 0 {
                        insetsCounters = counterInterSpacing * CGFloat(number + 1)
                        counterHeight = (userInfoView.frame.width - insetsCounters) / CGFloat(number)
                        totalCounterHeight = CGFloat(number) * counterHeight
                        leftX = counterInterSpacing
                    }
                    
                    if profile.friendsCount >= 0 {
                        let label1 = UILabel()
                        label1.text = profile.friendsCount.getCounterToString()
                        //label1.textColor = label1.tintColor
                        label1.textAlignment = .center
                        label1.font = UIFont(name: "Verdana-Bold", size: 16)
                        label1.adjustsFontSizeToFitWidth = true
                        label1.minimumScaleFactor = 0.5
                        label1.frame = CGRect(x: leftX, y: topY, width: counterHeight, height: counterHeight/2)
                        userInfoView.addSubview(label1)
                        
                        let label2 = UILabel()
                        label2.text = "друзья"
                        label2.isEnabled = false
                        label2.textAlignment = .center
                        label2.font = UIFont(name: "Verdana", size: 10)
                        label2.adjustsFontSizeToFitWidth = true
                        label2.minimumScaleFactor = 0.5
                        label2.frame = CGRect(x: leftX, y: topY + counterHeight/2, width: counterHeight, height: 20)
                        userInfoView.addSubview(label2)
                        
                        let tap = UITapGestureRecognizer()
                        tap.add {
                            self.delegate.openUsersController(uid: self.delegate.userID, title: "Друзья \(profile.firstNameGen)", type: "friends")
                        }
                        tap.numberOfTapsRequired = 1
                        label1.isUserInteractionEnabled = true
                        label1.addGestureRecognizer(tap)
                        
                        leftX += counterHeight + counterInterSpacing
                    }
                    
                    if profile.commonFriendsCount > 0 {
                        let label1 = UILabel()
                        label1.text = profile.commonFriendsCount.getCounterToString()
                        //label1.textColor = label1.tintColor
                        label1.textAlignment = .center
                        label1.font = UIFont(name: "Verdana-Bold", size: 16)
                        label1.adjustsFontSizeToFitWidth = true
                        label1.minimumScaleFactor = 0.5
                        label1.frame = CGRect(x: leftX, y: topY, width: counterHeight, height: counterHeight/2)
                        userInfoView.addSubview(label1)
                        
                        let label2 = UILabel()
                        label2.text = "общие друзья"
                        label2.isEnabled = false
                        label2.textAlignment = .center
                        label2.font = UIFont(name: "Verdana", size: 10)
                        label2.adjustsFontSizeToFitWidth = true
                        label2.minimumScaleFactor = 0.5
                        label2.frame = CGRect(x: leftX, y: topY + counterHeight/2, width: counterHeight, height: 20)
                        userInfoView.addSubview(label2)
                        
                        let tap = UITapGestureRecognizer()
                        tap.add {
                            self.delegate.openUsersController(uid: self.delegate.userID, title: "Общие друзья c \(profile.firstNameIns)", type: "commonFriends")
                        }
                        tap.numberOfTapsRequired = 1
                        label1.isUserInteractionEnabled = true
                        label1.addGestureRecognizer(tap)
                        
                        leftX += counterHeight + counterInterSpacing
                    }
                    
                    if profile.followersCount > 0 {
                        let label1 = UILabel()
                        label1.text = profile.followersCount.getCounterToString()
                        //label1.textColor = label1.tintColor
                        label1.textAlignment = .center
                        label1.font = UIFont(name: "Verdana-Bold", size: 16)
                        label1.adjustsFontSizeToFitWidth = true
                        label1.minimumScaleFactor = 0.5
                        label1.frame = CGRect(x: leftX, y: topY, width: counterHeight, height: counterHeight/2)
                        userInfoView.addSubview(label1)
                        
                        let label2 = UILabel()
                        label2.text = "подписчики"
                        label2.isEnabled = false
                        label2.textAlignment = .center
                        label2.font = UIFont(name: "Verdana", size: 10)
                        label2.adjustsFontSizeToFitWidth = true
                        label2.minimumScaleFactor = 0.5
                        label2.frame = CGRect(x: leftX, y: topY + counterHeight/2, width: counterHeight, height: 20)
                        userInfoView.addSubview(label2)
                        
                        let tap = UITapGestureRecognizer()
                        tap.add {
                            self.delegate.openUsersController(uid: self.delegate.userID, title: "Подписчики \(profile.firstNameGen)", type: "followers")
                        }
                        tap.numberOfTapsRequired = 1
                        label1.isUserInteractionEnabled = true
                        label1.addGestureRecognizer(tap)
                        
                        leftX += counterHeight + counterInterSpacing
                    }
                    
                    if profile.groupsCount - profile.pagesCount > 0 {
                        let label1 = UILabel()
                        label1.text = (profile.groupsCount - profile.pagesCount).getCounterToString()
                        //label1.textColor = label1.tintColor
                        label1.textAlignment = .center
                        label1.font = UIFont(name: "Verdana-Bold", size: 16)
                        label1.adjustsFontSizeToFitWidth = true
                        label1.minimumScaleFactor = 0.5
                        label1.frame = CGRect(x: leftX, y: topY, width: counterHeight, height: counterHeight/2)
                        userInfoView.addSubview(label1)
                        
                        let label2 = UILabel()
                        label2.text = "группы"
                        label2.isEnabled = false
                        label2.textAlignment = .center
                        label2.font = UIFont(name: "Verdana", size: 10)
                        label2.adjustsFontSizeToFitWidth = true
                        label2.minimumScaleFactor = 0.5
                        label2.frame = CGRect(x: leftX, y: topY + counterHeight/2, width: counterHeight, height: 20)
                        userInfoView.addSubview(label2)
                        
                        let tap = UITapGestureRecognizer()
                        tap.add {
                            var title = "Мои группы"
                            if self.delegate.userID != vkSingleton.shared.userID {
                                title = "Группы \(profile.firstNameGen)"
                            }
                            
                            self.delegate.openGroupsListController(uid: self.delegate.userID, title: title, type: "groups")
                        }
                        tap.numberOfTapsRequired = 1
                        label1.isUserInteractionEnabled = true
                        label1.addGestureRecognizer(tap)
                        
                        leftX += counterHeight + counterInterSpacing
                    }
                    
                    if profile.pagesCount > 0 {
                        let label1 = UILabel()
                        label1.text = profile.pagesCount.getCounterToString()
                        //label1.textColor = label1.tintColor
                        label1.textAlignment = .center
                        label1.font = UIFont(name: "Verdana-Bold", size: 16)
                        label1.adjustsFontSizeToFitWidth = true
                        label1.minimumScaleFactor = 0.5
                        label1.frame = CGRect(x: leftX, y: topY, width: counterHeight, height: counterHeight/2)
                        userInfoView.addSubview(label1)
                        
                        let label2 = UILabel()
                        label2.text = "страницы"
                        label2.isEnabled = false
                        label2.textAlignment = .center
                        label2.font = UIFont(name: "Verdana", size: 10)
                        label2.adjustsFontSizeToFitWidth = true
                        label2.minimumScaleFactor = 0.5
                        label2.frame = CGRect(x: leftX, y: topY + counterHeight/2, width: counterHeight, height: 20)
                        userInfoView.addSubview(label2)
                        
                        let tap = UITapGestureRecognizer()
                        tap.add {
                            var title = "Мои страницы"
                            if self.delegate.userID != vkSingleton.shared.userID {
                                title = "Страницы \(profile.firstNameGen)"
                            }
                            
                            self.delegate.openGroupsListController(uid: self.delegate.userID, title: title, type: "pages")
                        }
                        tap.numberOfTapsRequired = 1
                        label1.isUserInteractionEnabled = true
                        label1.addGestureRecognizer(tap)
                        
                        leftX += counterHeight + counterInterSpacing
                    }
                    
                    if profile.photosCount > 0 {
                        let label1 = UILabel()
                        label1.text = profile.photosCount.getCounterToString()
                        label1.textAlignment = .center
                        label1.font = UIFont(name: "Verdana-Bold", size: 16)
                        label1.adjustsFontSizeToFitWidth = true
                        label1.minimumScaleFactor = 0.5
                        label1.frame = CGRect(x: leftX, y: topY, width: counterHeight, height: counterHeight/2)
                        userInfoView.addSubview(label1)
                        
                        let label2 = UILabel()
                        label2.text = "фото"
                        label2.isEnabled = false
                        label2.textAlignment = .center
                        label2.font = UIFont(name: "Verdana", size: 10)
                        label2.adjustsFontSizeToFitWidth = true
                        label2.minimumScaleFactor = 0.5
                        label2.frame = CGRect(x: leftX, y: topY + counterHeight/2, width: counterHeight, height: 20)
                        userInfoView.addSubview(label2)
                        
                        leftX += counterHeight + counterInterSpacing
                    }
                    
                    if profile.videosCount > 0 {
                        let label1 = UILabel()
                        label1.text = profile.videosCount.getCounterToString()
                        label1.textAlignment = .center
                        label1.font = UIFont(name: "Verdana-Bold", size: 16)
                        label1.adjustsFontSizeToFitWidth = true
                        label1.minimumScaleFactor = 0.5
                        label1.frame = CGRect(x: leftX, y: topY, width: counterHeight, height: counterHeight/2)
                        userInfoView.addSubview(label1)
                        
                        let label2 = UILabel()
                        label2.text = "видео"
                        label2.isEnabled = false
                        label2.textAlignment = .center
                        label2.font = UIFont(name: "Verdana", size: 10)
                        label2.adjustsFontSizeToFitWidth = true
                        label2.minimumScaleFactor = 0.5
                        label2.frame = CGRect(x: leftX, y: topY + counterHeight/2, width: counterHeight, height: 20)
                        userInfoView.addSubview(label2)
                        
                        let tap = UITapGestureRecognizer()
                        tap.add {
                            var title = "Мои видеозаписи"
                            if self.delegate.userID != vkSingleton.shared.userID {
                                title = "Видеозаписи \(profile.firstNameGen)"
                            }
                            
                            self.delegate.openVideoListController(ownerID: self.delegate.userID, title: title, type: "")
                        }
                        tap.numberOfTapsRequired = 1
                        label1.isUserInteractionEnabled = true
                        label1.addGestureRecognizer(tap)
                        
                        leftX += counterHeight + counterInterSpacing
                    }
                    topY += counterHeight
                }
            } else {
                setSeparator(inView: userInfoView, topY: topY)
                topY += 1
            }
        }
        
        return topY
    }
    
    func setAvatarImage() {
        avatarImage.frame = CGRect(x: 10, y: 10, width: avatarHeight, height: avatarHeight)
        
        if let profile = user {
            var hasCropPhoto = 1
            let cropWidth = (profile.cropX2 - profile.cropX1) / 100.0 * Double(profile.photoWidth)
            let cropHeight = (profile.cropY2 - profile.cropY1) / 100.0 * Double(profile.photoHeight)
            let rectWidth = (profile.rectX2 - profile.rectX1) / 100.0 * Double(cropWidth)
            let rectHeight = (profile.rectY2 - profile.rectY1) / 100.0 * Double(cropHeight)
            
            if cropWidth == 0 || cropHeight == 0 || rectWidth == 0 || rectHeight == 0 {
                hasCropPhoto = 0
            }
            
            if profile.hasPhoto == 0 {
                let getCacheImage = GetCacheImage(url: profile.maxPhotoOrigURL, lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        self.avatarImage.image = getCacheImage.outputImage
                        self.avatarImage.contentMode = .scaleAspectFit
                    }
                }
                OperationQueue().addOperation(getCacheImage)
            } else if hasCropPhoto == 0 {
                let ids = profile.avatarID.components(separatedBy: "_")
                if ids.count > 0 {
                    let ownerID = ids[0]
                    let photoID = ids[1]
                    
                    let url = "/method/photos.getById"
                    let parameters = [
                        "access_token":"\(vkSingleton.shared.accessToken)",
                        "photos":"\(ownerID)_\(photoID)",
                        "extended":"1",
                        "v":"\(vkSingleton.shared.version)"
                    ]
                    
                    let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                    getServerDataOperation.completionBlock = {
                        guard let data = getServerDataOperation.data else { return }
                        
                        guard let json = try? JSON(data: data) else { print("json error"); return }
                        let photos = json["response"].compactMap { Photo(json: $0.1) }
                        if photos.count > 0 {
                            let getCacheImage = GetCacheImage(url: photos[0].photo604, lifeTime: .avatarImage)
                            getCacheImage.completionBlock = {
                                OperationQueue.main.addOperation {
                                    self.avatarImage.image = getCacheImage.outputImage
                                    self.avatarImage.contentMode = .scaleAspectFill
                                }
                            }
                            OperationQueue().addOperation(getCacheImage)
                        } else {
                            let getCacheImage = GetCacheImage(url: profile.maxPhotoOrigURL, lifeTime: .avatarImage)
                            getCacheImage.completionBlock = {
                                OperationQueue.main.addOperation {
                                    self.avatarImage.image = getCacheImage.outputImage
                                    self.avatarImage.contentMode = .scaleAspectFit
                                }
                            }
                            OperationQueue().addOperation(getCacheImage)
                        }
                    }
                    OperationQueue().addOperation(getServerDataOperation)
                } else {
                    let getCacheImage = GetCacheImage(url: profile.maxPhotoOrigURL, lifeTime: .avatarImage)
                    getCacheImage.completionBlock = {
                        OperationQueue.main.addOperation {
                            self.avatarImage.image = getCacheImage.outputImage
                            self.avatarImage.contentMode = .scaleAspectFit
                        }
                    }
                    OperationQueue().addOperation(getCacheImage)
                }
            } else {
                let cropX1 = profile.cropX1 / 100 * Double(profile.photoWidth)
                let cropY1 = profile.cropY1 / 100 * Double(profile.photoHeight)
                
                let rectX1 = profile.rectX1 / 100 * cropWidth
                let rectY1 = profile.rectY1 / 100 * cropHeight
                
                let getCacheImage = GetCacheImage(url: profile.cropPhotoURL, lifeTime: .avatarImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        let cropRect = CGRect(x: cropX1, y: cropY1, width: cropWidth, height: cropHeight)
                        if let cropImage = getCacheImage.outputImage?.cropImage(cropRect: cropRect, viewWidth: CGFloat(profile.photoWidth), viewHeight: CGFloat(profile.photoHeight)) {
                            let rect = CGRect(x: rectX1, y: rectY1, width: rectWidth, height: rectHeight)
                            let rectImage = cropImage.cropImage(cropRect: rect, viewWidth: CGFloat(cropWidth), viewHeight: CGFloat(cropHeight))
                            self.avatarImage.image = rectImage
                            self.avatarImage.contentMode = .scaleAspectFill
                        }
                    }
                }
                OperationQueue().addOperation(getCacheImage)
                
                OperationQueue.main.addOperation {
                    self.avatarImage.layer.borderWidth = 0.6
                    self.avatarImage.layer.borderColor = UIColor.gray.cgColor
                    self.avatarImage.clipsToBounds = true
                }
            }
            
            let tap = UITapGestureRecognizer()
            avatarImage.isUserInteractionEnabled = true
            avatarImage.addGestureRecognizer(tap)
            tap.add {
                var photos: [Photo] = []
                var numPhoto = -1
                
                let comps = profile.avatarID.components(separatedBy: "_")
                if comps.count > 1, let ownerID = Int(comps[0]), let id = Int(comps[1]) {
                    
                    let photo = Photo(json: JSON.null)
                    photo.ownerID = ownerID
                    photo.id = id
                    
                    if self.photos.count > 0 {
                        for index in 0...self.photos.count - 1 {
                            if photo.id == self.photos[index].id {
                                numPhoto = index
                                photos = self.photos
                            }
                        }
                    }
                    
                    if numPhoto == -1 && photos.count == 0 {
                        photo.photo807 = profile.maxPhotoOrigURL
                        photo.photo604 = profile.maxPhotoOrigURL
                        photo.photo1280 = profile.maxPhotoOrigURL
                        photo.photo2560 = profile.maxPhotoOrigURL
                        photo.width = Int(self.delegate.tableView.bounds.width)
                        photo.height = Int(self.delegate.tableView.bounds.width)
                        
                        numPhoto = 0
                        photos.append(photo)
                    }
                }
                
                self.delegate.openPhotoViewController(numPhoto: numPhoto, photos: photos)
            }
        }
    }
    
    func setSeparator(inView view: UIView, topY: CGFloat) {
        let separator = UIView()
        separator.frame = CGRect(x: 10, y: topY, width: view.bounds.width - 20, height: 0.8)
        separator.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.8)
        separator.layer.borderWidth = 0.1
        separator.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(separator)
    }
    
    func getNumberOfCounters() -> Int {
        var num = 0
        
        if let profile = user {
            if profile.friendsCount >= 0 {
                num += 1
            }
            
            if profile.commonFriendsCount > 0 {
                num += 1
            }
            
            if profile.followersCount > 0 {
                num += 1
            }
            
            if profile.groupsCount - profile.pagesCount > 0 {
                num += 1
            }
            
            if profile.pagesCount > 0 {
                num += 1
            }
            
            if profile.photosCount > 0 {
                num += 1
            }
            
            if profile.videosCount > 0 {
                num += 1
            }
        }
        
        return num
    }
    
    func updateFriendButton() {
        
        if let profile = user {
            if profile.friendStatus == 0 {
                if profile.canSendFriendRequest == 1 {
                    friendButton.setTitle("Заявка в друзья", for: UIControlState.normal)
                    friendButton.isEnabled = true
                    friendButton.backgroundColor = vkSingleton.shared.mainColor
                } else {
                    friendButton.setTitle("Вы не друзья", for: UIControlState.disabled)
                    friendButton.isEnabled = false
                    friendButton.backgroundColor = UIColor.lightGray
                }
            }
        
            if profile.friendStatus == 1 {
                friendButton.setTitle("Отправлена заявка", for: UIControlState.normal)
                friendButton.isEnabled = true
                friendButton.backgroundColor = UIColor.lightGray
            }
            
            if profile.friendStatus == 2 {
                friendButton.setTitle("Получена заявка", for: UIControlState.normal)
                friendButton.isEnabled = true
                friendButton.backgroundColor = vkSingleton.shared.mainColor
            }
            
            if profile.friendStatus == 3 {
                friendButton.setTitle("Вы являетесь друзьями", for: UIControlState.normal)
                friendButton.isEnabled = true
                friendButton.backgroundColor = UIColor.lightGray
            }
        }
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
        
        if let profile = user {
            allRecordsButton.setTitle("Все записи", for: .normal)
            allRecordsButton.setTitle("Все записи", for: .selected)
            allRecordsButton.titleLabel?.font = UIFont(name: "Verdana", size: 12)!
            allRecordsButton.titleLabel?.adjustsFontSizeToFitWidth = true
            allRecordsButton.titleLabel?.minimumScaleFactor = 0.5
            
            allRecordsButton.frame = CGRect(x: view.bounds.width / 2 - 80, y: 5, width: 160, height: buttonHeight)
            
            if delegate.userID == vkSingleton.shared.userID {
                ownerButton.setTitle("Мои записи", for: .selected)
                ownerButton.setTitle("Мои записи", for: .normal)
            } else {
                ownerButton.setTitle("Записи \(profile.firstNameGen)", for: .selected)
                ownerButton.setTitle("Записи \(profile.firstNameGen)", for: .normal)
            }
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
    }
    
    func setRecordsButton(view: UIView, topY: CGFloat) {
        
        if let profile = user {
            if profile.canPost == 1 {
                newRecordButton.setTitle("Новая запись", for: .normal)
                newRecordButton.setTitleColor(newRecordButton.tintColor, for: .normal)
                newRecordButton.setTitleColor(UIColor.black, for: .highlighted)
                newRecordButton.setTitleColor(UIColor.black, for: .selected)
                newRecordButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
                newRecordButton.contentHorizontalAlignment = .left
                newRecordButton.contentMode = .center
                
                newRecordButton.add(for: .touchUpInside) {
                    self.newRecordButton.buttonTouched()
                }
                
                newRecordButton.frame = CGRect(x: 10, y: 5, width: 100, height: buttonHeight)
                view.addSubview(newRecordButton)
            }
            
            if delegate.postponedWall.count > 0 {
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
                postponedButton.frame = CGRect(x: view.bounds.width / 2 - 80, y: 5, width: 160, height: buttonHeight)
                view.addSubview(postponedButton)
            }
            
            recordsCountLabel.text = "Всего записей: \(delegate.recordsCount)"
            recordsCountLabel.textAlignment = .right
            recordsCountLabel.textColor = recordsCountLabel.tintColor
            recordsCountLabel.font = UIFont(name: "Verdana", size: 13)!
            
            recordsCountLabel.frame = CGRect(x: view.bounds.width - 10 - 150, y: 5, width: 150, height: buttonHeight)
            view.addSubview(recordsCountLabel)
        }
    }
}
