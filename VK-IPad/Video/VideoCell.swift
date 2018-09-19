//
//  VideoCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 23.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON

class VideoCell: UITableViewCell {

    weak var delegate: VideoController!
    weak var video: Video!
    var users: [UserProfile]!
    var groups: [GroupProfile]!
    
    var likes: [Likes]!
    var reposts: [Likes]!

    var indexPath: IndexPath!
    weak var cell: UITableViewCell!
    weak var tableView: UITableView!
    
    var cellWidth: CGFloat = 0
    
    let avatarHeight: CGFloat = 50
    
    let nameFont = UIFont(name: "Verdana-Bold", size: 13)!
    let titleFont = UIFont(name: "Verdana-Bold", size: 13)!
    let descFont = UIFont(name: "Verdana", size: 14)!
    
    let likesHeight: CGFloat = 35
    
    var likesButton = UIButton()
    var repostsButton = UIButton()
    var commentsButton = UIButton()
    var viewsButton = UIButton()
    
    let infoPanelHeight: CGFloat = 35
    let infoAvatarHeight: CGFloat = 33
    let infoAvatarTrailing: CGFloat = -5.0
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        
        if video != nil {
            
            var topY: CGFloat = 0
            
            topY = setHeader(topY: topY)
            
            topY = setVideo(topY: topY)
            
            topY = setInfoView(topY: topY)
            
            topY = setInfoLikePanel(topY: topY)
            topY += 5
            
            setSeparator(inView: self, topY: topY)
            topY = setLikesPanel(topY: topY)
        }
    }
    
    func setHeader(topY: CGFloat) -> CGFloat {
        
        var url = ""
        var name = ""
        
        let avatarImage = UIImageView()
        let nameLabel = UILabel()
        let dateLabel = UILabel()
        
        avatarImage.tag = 250
        nameLabel.tag = 250
        dateLabel.tag = 250
        
        if video.ownerID > 0 {
            let user = users.filter({ $0.uid == "\(video.ownerID)" })
            if user.count > 0 {
                url = user[0].photo100
                name = "\(user[0].firstName) \(user[0].lastName)"
            }
        } else if video.ownerID < 0 {
            let group = groups.filter({ $0.gid == abs(video.ownerID) })
            if group.count > 0 {
                url = group[0].photo100
                name = group[0].name
            }
        }
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                avatarImage.image = getCacheImage.outputImage
                avatarImage.layer.cornerRadius = self.avatarHeight/2
                avatarImage.clipsToBounds = true
            }
        }
        OperationQueue().addOperation(getCacheImage)
        
        nameLabel.text = name
        nameLabel.font = nameFont
        
        dateLabel.text = video.date.toStringLastTime()
        dateLabel.font = UIFont(name: "Verdana", size: 11)!
        dateLabel.isEnabled = false
        
        avatarImage.frame = CGRect(x: 10, y: topY + 5, width: avatarHeight, height: avatarHeight)
        nameLabel.frame = CGRect(x: avatarImage.frame.maxX + 10, y: avatarImage.frame.midY - 20, width: cellWidth - avatarImage.frame.maxX - 20, height: 20)
        dateLabel.frame = CGRect(x: avatarImage.frame.maxX + 10, y: avatarImage.frame.midY, width: cellWidth - avatarImage.frame.maxX - 20, height: 16)
        
        let tap1 = UITapGestureRecognizer()
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tap1)
        tap1.add {
            self.delegate.openProfileController(id: self.video.ownerID, name: name)
        }
        
        let tap2 = UITapGestureRecognizer()
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(tap2)
        tap2.add {
            self.delegate.openProfileController(id: self.video.ownerID, name: name)
        }
        
        let tap3 = UITapGestureRecognizer()
        dateLabel.isUserInteractionEnabled = true
        dateLabel.addGestureRecognizer(tap3)
        tap3.add {
            self.delegate.openProfileController(id: self.video.ownerID, name: name)
        }
        
        self.addSubview(avatarImage)
        self.addSubview(nameLabel)
        self.addSubview(dateLabel)
        
        return topY + 5 + avatarHeight + 10
    }
    
    func setVideo(topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        let maxSize = cellWidth - 40
        
        let videoWidth: CGFloat = maxSize - 40
        let videoHeight: CGFloat = 240 * videoWidth / 320
        
        let view = UIView()
        view.tag = 250
        view.backgroundColor = UIColor.black
        
        view.frame = CGRect(x: 40, y: topY, width: videoWidth, height: videoHeight)
        self.addSubview(view)
        
        let loadingView = UIView()
        loadingView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        loadingView.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2)
        loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 8.5
        view.addSubview(loadingView)
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: loadingView.frame.maxX, height: loadingView.frame.maxY);
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.width/2, y: loadingView.frame.height/2)
        loadingView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        let webView = WKWebView()
        webView.tag = 250
        webView.isOpaque = false
        webView.frame = CGRect(x: 40, y: topY, width: videoWidth, height: videoHeight)
        webView.navigationDelegate = delegate
        
        if video.player == "" {
            let url = "/method/video.get"
            let parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "owner_id": "\(video.ownerID)",
                "videos": "\(video.ownerID)_\(video.id)_\(video.accessKey)",
                "v": vkSingleton.shared.version
            ]
            let getServerData = GetServerDataOperation(url: url, parameters: parameters)
            getServerData.completionBlock = {
                guard let data = getServerData.data else { return }
                guard let json = try? JSON(data: data) else { print("json error"); return }
                
                let videos = json["response"]["items"].compactMap({ Video(json: $0.1) })
                if videos.count > 0 {
                    if let url = URL(string: videos[0].player) {
                        let request = URLRequest(url: url)
                        OperationQueue.main.addOperation {
                            webView.load(request)
                            self.addSubview(webView)
                        }
                    }
                }
            }
            OperationQueue().addOperation(getServerData)
        } else {
            if let url = URL(string: video.player) {
                let request = URLRequest(url: url)
                webView.load(request)
                self.addSubview(webView)
            }
        }
        
        if video.addingDate != 0 {
            let addedLabel = UILabel()
            addedLabel.tag = 250
            addedLabel.frame = CGRect(x: 40, y: webView.frame.maxY, width: videoWidth/2, height: 20)
            addedLabel.text = "Добавлено: \(video.addingDate.toStringLastTime())"
            addedLabel.isEnabled = false
            addedLabel.textAlignment = .left
            addedLabel.font = UIFont(name: "Verdana", size: 12)!
            
            self.addSubview(addedLabel)
        }
        
        
        let durationLabel = UILabel()
        durationLabel.tag = 250
        durationLabel.frame = CGRect(x: 40 + videoWidth/2, y: webView.frame.maxY, width: videoWidth/2, height: 20)
        if video.duration != 0 {
            durationLabel.text = "Продолжительность видео: \(video.duration.getVideoDurationToString())"
            durationLabel.isEnabled = false
        } else {
            durationLabel.text = "🔴 Прямая трансляция"
            durationLabel.isEnabled = true
            durationLabel.textColor = UIColor.red
        }
        
        durationLabel.textAlignment = .right
        durationLabel.font = UIFont(name: "Verdana", size: 12)!
        
        self.addSubview(durationLabel)
        
        topY += videoHeight + 25
        
        return topY
    }
    
    func setInfoView(topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        let maxSize = cellWidth - 40
        
        let titleLabel = UILabel()
        titleLabel.text = video.title
        titleLabel.font = titleFont
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.prepareTextForPublish2(delegate, cell: self)
        
        let titleSize = delegate.getTextSize(text: titleLabel.text!, font: titleLabel.font, maxWidth: maxSize)
        titleLabel.frame = CGRect(x: 20, y: topY, width: maxSize, height: titleSize.height + 10)
        self.addSubview(titleLabel)
        topY += titleSize.height + 10
        
        let descLabel = UILabel()
        if video.description != "" {
            descLabel.text = video.description
            descLabel.isEnabled = true
        } else {
            descLabel.text = "Описание к видео отсутствует"
            descLabel.isEnabled = false
        }
        descLabel.font = descFont
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.prepareTextForPublish2(delegate, cell: self)
        
        let descSize = delegate.getTextSize(text: descLabel.text!, font: descLabel.font, maxWidth: maxSize)
        descLabel.frame = CGRect(x: 20, y: topY, width: maxSize, height: descSize.height + 10)
        self.addSubview(descLabel)
        topY += descSize.height + 10
        
        return topY
    }
    
    func setInfoLikePanel(topY: CGFloat) -> CGFloat {
        
        let maxWidth = cellWidth - 40
        
        var countFriends = 0
        var info = "Понравилось"
        
        let infoLikesLabel = UILabel()
        let infoAvatar1 = UIImageView()
        let infoAvatar2 = UIImageView()
        let infoAvatar3 = UIImageView()
        
        infoLikesLabel.tag = 250
        infoAvatar1.tag = 250
        infoAvatar2.tag = 250
        infoAvatar3.tag = 250
        
        if let likes = self.likes {
            for like in likes {
                if like.uid != vkSingleton.shared.userID {
                    if like.friendStatus == 3 {
                        countFriends += 1
                        
                        if countFriends == 1 {
                            let getCacheImage = GetCacheImage(url: like.maxPhotoURL, lifeTime: .avatarImage)
                            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar1, indexPath: indexPath, tableView: tableView)
                            setImageToRow.addDependency(getCacheImage)
                            OperationQueue().addOperation(getCacheImage)
                            OperationQueue.main.addOperation(setImageToRow)
                            if video.userLikes == 1 {
                                info = "\(info) Вам, \(like.firstNameDat)"
                            } else {
                                info = "\(info) \(like.firstNameDat)"
                            }
                            
                            let tap = UITapGestureRecognizer()
                            infoAvatar1.isUserInteractionEnabled = true
                            infoAvatar1.addGestureRecognizer(tap)
                            tap.add {
                                if let id = Int(like.uid) {
                                    self.delegate.openProfileController(id: id, name: "\(like.firstName) \(like.lastName)")
                                }
                            }
                        }
                        if countFriends == 2 {
                            let getCacheImage = GetCacheImage(url: like.maxPhotoURL, lifeTime: .avatarImage)
                            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar2, indexPath: indexPath, tableView: tableView)
                            setImageToRow.addDependency(getCacheImage)
                            OperationQueue().addOperation(getCacheImage)
                            OperationQueue.main.addOperation(setImageToRow)
                            info = "\(info), \(like.firstNameDat)"
                            
                            let tap = UITapGestureRecognizer()
                            infoAvatar2.isUserInteractionEnabled = true
                            infoAvatar2.addGestureRecognizer(tap)
                            tap.add {
                                if let id = Int(like.uid) {
                                    self.delegate.openProfileController(id: id, name: "\(like.firstName) \(like.lastName)")
                                }
                            }
                        }
                        if countFriends == 3 {
                            let getCacheImage = GetCacheImage(url: like.maxPhotoURL, lifeTime: .avatarImage)
                            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar3, indexPath: indexPath, tableView: tableView)
                            setImageToRow.addDependency(getCacheImage)
                            OperationQueue().addOperation(getCacheImage)
                            OperationQueue.main.addOperation(setImageToRow)
                            info = "\(info), \(like.firstNameDat)"
                            
                            let tap = UITapGestureRecognizer()
                            infoAvatar3.isUserInteractionEnabled = true
                            infoAvatar3.addGestureRecognizer(tap)
                            tap.add {
                                if let id = Int(like.uid) {
                                    self.delegate.openProfileController(id: id, name: "\(like.firstName) \(like.lastName)")
                                }
                            }
                        }
                        if countFriends == 3 { break }
                    }
                }
            }
            
            if (countFriends > 0) {
                var total = 0
                if video.userLikes == 1 {
                    total = video.countLikes - countFriends - 1
                } else {
                    total = video.countLikes - countFriends
                }
                if total > 0 {
                    if total == 1 {
                        info = "\(info) и еще 1 человеку"
                    } else {
                        info = "\(info) и еще \(total) людям"
                    }
                }
            } else {
                var count = 0
                if video.userLikes == 1 {
                    count = video.countLikes - 1
                    if count == 0 {
                        info = "Понравилось только Вам"
                    } else if count == 1 {
                        info = "Понравилось Вам и еще 1 человеку"
                    } else {
                        info = "Понравилось Вам и еще \(count) людям"
                    }
                } else {
                    count = video.countLikes
                    if count == 1 {
                        info = "Понравилось 1 человеку"
                    } else {
                        info = "Понравилось \(count) людям"
                    }
                }
                
                if count > 0 {
                    countFriends += 1
                    if likes.count > 0 {
                        let getCacheImage = GetCacheImage(url: likes[0].maxPhotoURL, lifeTime: .avatarImage)
                        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar1, indexPath: indexPath, tableView: tableView)
                        setImageToRow.addDependency(getCacheImage)
                        OperationQueue().addOperation(getCacheImage)
                        OperationQueue.main.addOperation(setImageToRow)
                        
                        let tap = UITapGestureRecognizer()
                        infoAvatar1.isUserInteractionEnabled = true
                        infoAvatar1.addGestureRecognizer(tap)
                        tap.add {
                            if let id = Int(likes[0].uid) {
                                self.delegate.openProfileController(id: id, name: "\(likes[0].firstName) \(likes[0].lastName)")
                            }
                        }
                    }
                }
                if count > 1 {
                    countFriends += 1
                    if likes.count > 0 {
                        let getCacheImage = GetCacheImage(url: likes[1].maxPhotoURL, lifeTime: .avatarImage)
                        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar2, indexPath: indexPath, tableView: tableView)
                        setImageToRow.addDependency(getCacheImage)
                        OperationQueue().addOperation(getCacheImage)
                        OperationQueue.main.addOperation(setImageToRow)
                        
                        let tap = UITapGestureRecognizer()
                        infoAvatar2.isUserInteractionEnabled = true
                        infoAvatar2.addGestureRecognizer(tap)
                        tap.add {
                            if let id = Int(likes[1].uid) {
                                self.delegate.openProfileController(id: id, name: "\(likes[1].firstName) \(likes[1].lastName)")
                            }
                        }
                    }
                }
                if count > 2 {
                    countFriends += 1
                    if likes.count > 0 {
                        let getCacheImage = GetCacheImage(url: likes[2].maxPhotoURL, lifeTime: .avatarImage)
                        let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: infoAvatar3, indexPath: indexPath, tableView: tableView)
                        setImageToRow.addDependency(getCacheImage)
                        OperationQueue().addOperation(getCacheImage)
                        OperationQueue.main.addOperation(setImageToRow)
                        
                        let tap = UITapGestureRecognizer()
                        infoAvatar3.isUserInteractionEnabled = true
                        infoAvatar3.addGestureRecognizer(tap)
                        tap.add {
                            if let id = Int(likes[2].uid) {
                                self.delegate.openProfileController(id: id, name: "\(likes[2].firstName) \(likes[2].lastName)")
                            }
                        }
                    }
                }
            }
            
            infoLikesLabel.text = info
            infoLikesLabel.font = UIFont(name: "Verdana", size: 12)!
            infoLikesLabel.numberOfLines = 2
            infoLikesLabel.isEnabled = false
            
            let tap = UITapGestureRecognizer()
            infoLikesLabel.isUserInteractionEnabled = true
            infoLikesLabel.addGestureRecognizer(tap)
            tap.add {
                if let likes = self.likes, let reposts = self.reposts {
                    self.delegate.openLikesUsersController(likes: likes, reposts: reposts)
                }
            }
            
            if countFriends == 0 {
                infoLikesLabel.frame = CGRect(x: 10, y: topY, width: maxWidth - 20, height: infoPanelHeight)
                
                self.addSubview(infoLikesLabel)
            }
            
            if countFriends == 1 {
                infoAvatar1.frame = CGRect(x: 10, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0, width: infoAvatarHeight, height: infoAvatarHeight)
                
                infoLikesLabel.frame = CGRect(x: infoAvatar1.frame.maxX + 5, y: topY, width: maxWidth - 10 - infoAvatar1.frame.maxX - 5, height: infoPanelHeight)
                
                infoAvatar1.layer.cornerRadius = infoAvatarHeight/2
                infoAvatar1.layer.borderColor = UIColor.white.cgColor
                infoAvatar1.layer.borderWidth = 1.5
                infoAvatar1.clipsToBounds = true
                infoAvatar1.contentMode = .scaleAspectFit
                
                self.addSubview(infoAvatar1)
                self.addSubview(infoLikesLabel)
            }
            
            if countFriends == 2 {
                infoAvatar1.frame = CGRect(x: 10, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0, width: infoAvatarHeight, height: infoAvatarHeight)
                
                infoAvatar2.frame = CGRect(x: infoAvatar1.frame.maxX + infoAvatarTrailing, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0, width: infoAvatarHeight, height: infoAvatarHeight)
                
                infoLikesLabel.frame = CGRect(x: infoAvatar2.frame.maxX + 5, y: topY, width: maxWidth - 10 - infoAvatar2.frame.maxX - 5, height: infoPanelHeight)
                
                infoAvatar1.layer.cornerRadius = infoAvatarHeight/2
                infoAvatar1.layer.borderColor = UIColor.white.cgColor
                infoAvatar1.layer.borderWidth = 1.5
                infoAvatar1.clipsToBounds = true
                infoAvatar1.contentMode = .scaleAspectFit
                
                infoAvatar2.layer.cornerRadius = infoAvatarHeight/2
                infoAvatar2.layer.borderColor = UIColor.white.cgColor
                infoAvatar2.layer.borderWidth = 1.5
                infoAvatar2.clipsToBounds = true
                infoAvatar2.contentMode = .scaleAspectFit
                
                self.addSubview(infoAvatar1)
                self.addSubview(infoAvatar2)
                self.addSubview(infoLikesLabel)
            }
            
            if countFriends > 2 {
                infoAvatar1.frame = CGRect(x: 10, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0, width: infoAvatarHeight, height: infoAvatarHeight)
                
                infoAvatar2.frame = CGRect(x: infoAvatar1.frame.maxX + infoAvatarTrailing, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0 , width: infoAvatarHeight, height: infoAvatarHeight)
                
                infoAvatar3.frame = CGRect(x: infoAvatar2.frame.maxX + infoAvatarTrailing, y: topY + (infoPanelHeight - infoAvatarHeight) / 2.0 , width: infoAvatarHeight, height: infoAvatarHeight)
                
                infoLikesLabel.frame = CGRect(x: infoAvatar3.frame.maxX + 5, y: topY, width: maxWidth - 10 - infoAvatar3.frame.maxX - 5, height: infoPanelHeight)
                
                infoAvatar1.layer.cornerRadius = infoAvatarHeight/2
                infoAvatar1.layer.borderColor = UIColor.white.cgColor
                infoAvatar1.layer.borderWidth = 1.5
                infoAvatar1.clipsToBounds = true
                infoAvatar1.contentMode = .scaleAspectFit
                
                infoAvatar2.layer.cornerRadius = infoAvatarHeight/2
                infoAvatar2.layer.borderColor = UIColor.white.cgColor
                infoAvatar2.layer.borderWidth = 1.5
                infoAvatar2.clipsToBounds = true
                infoAvatar2.contentMode = .scaleAspectFit
                
                infoAvatar3.layer.cornerRadius = infoAvatarHeight/2
                infoAvatar3.layer.borderColor = UIColor.white.cgColor
                infoAvatar3.layer.borderWidth = 1.5
                infoAvatar3.clipsToBounds = true
                infoAvatar3.contentMode = .scaleAspectFit
                
                self.addSubview(infoAvatar1)
                self.addSubview(infoAvatar2)
                self.addSubview(infoAvatar3)
                self.addSubview(infoLikesLabel)
            }
        }
        
        return topY + infoPanelHeight
    }
    
    func setLikesPanel(topY: CGFloat) -> CGFloat {
        
        var topY = topY
        let maxWidth = cellWidth - 40
    
        let buttonWidth = maxWidth / 5
        
        likesButton.tag = 250
        likesButton.frame = CGRect(x: 20, y: topY, width: buttonWidth, height: likesHeight)
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
        
        repostsButton.tag = 250
        repostsButton.frame = CGRect(x: 20 + buttonWidth, y: topY, width: buttonWidth, height: likesHeight)
        repostsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
        repostsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        repostsButton.contentVerticalAlignment = .center
        
        repostsButton.setTitle("\(video.countReposts)", for: UIControlState.normal)
        repostsButton.setTitle("\(video.countReposts)", for: UIControlState.selected)
        repostsButton.setImage(UIImage(named: "repost"), for: .normal)
        repostsButton.imageView?.tintColor = UIColor.black
        repostsButton.setTitleColor(UIColor.black, for: .normal)
        if video.userReposted == 1 {
            repostsButton.setTitleColor(UIColor.purple, for: .normal)
            repostsButton.imageView?.tintColor = UIColor.purple
        }
        
        self.addSubview(repostsButton)
        
        let tap = UITapGestureRecognizer()
        tap.add {
            self.repostsButton.buttonTouched()
            self.repostObject(sender: tap)
        }
        repostsButton.isUserInteractionEnabled = true
        repostsButton.addGestureRecognizer(tap)
        
        commentsButton.tag = 250
        commentsButton.frame = CGRect(x: 20 + 3 * buttonWidth, y: topY, width: buttonWidth, height: likesHeight)
        commentsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
        commentsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        commentsButton.contentVerticalAlignment = .center
        
        commentsButton.setImage(UIImage(named: "comments"), for: .normal)
        commentsButton.setTitleColor(UIColor.init(red: 124/255, green: 172/255, blue: 238/255, alpha: 1), for: .normal)
        
        commentsButton.setTitle("\(video.comments)", for: UIControlState.normal)
        commentsButton.setTitle("\(video.comments)", for: UIControlState.selected)
        
        self.addSubview(commentsButton)
        
        viewsButton.tag = 250
        viewsButton.frame = CGRect(x: 20 + 4 * buttonWidth, y: topY, width: buttonWidth, height: likesHeight)
        viewsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
        viewsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        viewsButton.contentVerticalAlignment = .center
        
        viewsButton.setTitle("\(video.views.getCounterToString())", for: UIControlState.normal)
        viewsButton.setTitle("\(video.views.getCounterToString())", for: UIControlState.selected)
        viewsButton.setImage(UIImage(named: "views"), for: .normal)
        viewsButton.setTitleColor(UIColor.darkGray, for: .normal)
        viewsButton.isEnabled = false
        
        self.addSubview(viewsButton)
        
        topY += likesHeight
    
        return topY
    }
    
    func setLikesButton() {
        likesButton.setTitle("\(video.countLikes)", for: UIControlState.normal)
        likesButton.setTitle("\(video.countLikes)", for: UIControlState.selected)
        
        if video.userLikes == 1 {
            likesButton.setTitleColor(UIColor.purple, for: .normal)
            likesButton.setImage(UIImage(named: "like")?.tint(tintColor:  UIColor.purple), for: .normal)
        } else {
            likesButton.setTitleColor(UIColor.darkGray, for: .normal)
            likesButton.setImage(UIImage(named: "like")?.tint(tintColor:  UIColor.darkGray), for: .normal)
        }
    }
    
    func tapLikesButton() {
        if video.userLikes == 0 {
            let url = "/method/likes.add"
            var parameters = [
                "access_token": vkSingleton.shared.accessToken,
                "type": "video",
                "owner_id": "\(video.ownerID)",
                "item_id": "\(video.id)",
                "v": vkSingleton.shared.version
            ]
            
            if video.accessKey != "" {
                parameters["access_key"] = video.accessKey
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
                        self.video.countLikes += 1
                        self.video.userLikes = 1
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
                "type": "video",
                "owner_id": "\(video.ownerID)",
                "item_id": "\(video.id)",
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
                        self.video.countLikes -= 1
                        self.video.userLikes = 0
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
    
    func repostObject(sender: UITapGestureRecognizer) {
        
        let point = sender.location(in: self)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Скопировать ссылку в буфер", style: .default) { action in
            
            let link = "https://vk.com/video\(self.video.ownerID)_\(self.video.id)"
            
            UIPasteboard.general.string = link
            if let string = UIPasteboard.general.string {
                self.delegate.showInfoMessage(title: "Ссылка на видеозапись помещена в буфер обмена:" , msg: "\(string)")
            }
        }
        alertController.addAction(action1)
        
        
        let action2 = UIAlertAction(title: "Вложить в личное сообщение", style: .default) { action in
            
            vkSingleton.shared.repostObject = self.video
            self.delegate.showInfoMessage(title: "Репост видеозаписи", msg: "Перейдите в нужный диалог для отправки вашему собеседнику видеозаписи «\(self.video.title)»")
        }
        alertController.addAction(action2)
        
        
        let action3 = UIAlertAction(title: "Опубликовать на своей стене", style: .default) { action in
            
            self.delegate.repost(object: self.video)
        }
        alertController.addAction(action3)
        
        
        if vkSingleton.shared.adminGroups.count > 0 {
            let action4 = UIAlertAction(title: "Опубликовать в сообществе", style: .default) { action in
                
                let alertController2 = UIAlertController(title: "Выберите сообщество:", message: nil, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController2.addAction(cancelAction)
                
                
                for group in vkSingleton.shared.adminGroups {
                    let action = UIAlertAction(title: group.name, style: .default) { action in
                        
                        self.delegate.repostInGroup(object: self.video, groupID: group.gid)
                    }
                    alertController2.addAction(action)
                }
                
                if let popoverController = alertController2.popoverPresentationController {
                    popoverController.sourceView = self
                    popoverController.sourceRect = CGRect(x: point.x, y: point.y - 10, width: 0, height: 0)
                    popoverController.permittedArrowDirections = [.up,.down]
                }
                
                self.delegate.present(alertController2, animated: true)
            }
            alertController.addAction(action4)
        }
        
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self
            popoverController.sourceRect = CGRect(x: point.x, y: point.y - 10, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.up,.down]
        }
        
        delegate.present(alertController, animated: true)
    }
}

extension VideoCell {
    func getRowHeight() -> CGFloat {
        
        var height = 5 + avatarHeight + 10
        
        let maxWidth = cellWidth - 40
        let videoHeight: CGFloat = 240 * (maxWidth - 40) / 320
        height += videoHeight + 25
        
        let titleSize = delegate.getTextSize(text: video.title.prepareTextForPublic(), font: titleFont, maxWidth: maxWidth)
        height += titleSize.height + 10
        
        var desc = video.description.prepareTextForPublic()
        if video.description == "" {
            desc = "Описание к видео отсутствует"
        }
        let descSize = delegate.getTextSize(text: desc, font: descFont, maxWidth: maxWidth)
        height += descSize.height + 10
        
        height += 5
        
        height += infoPanelHeight
        height += likesHeight
        
        return height
    }
    
    func setSeparator(inView view: UIView, topY: CGFloat) {
        let separator = UIView()
        separator.tag = 250
        separator.frame = CGRect(x: 10, y: topY, width: cellWidth - 20, height: 0.8)
        separator.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.8)
        separator.layer.borderWidth = 0.1
        separator.layer.borderColor = UIColor.gray.cgColor
        view.addSubview(separator)
    }
}
