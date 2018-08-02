//
//  CommentCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 21.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON
import WebKit
import SCLAlertView

class CommentCell: UITableViewCell {

    var delegate: UIViewController!
    
    var comment: Comment!
    var users: [UserProfile]!
    var groups: [GroupProfile]!
    
    var cellWidth: CGFloat = 0
    
    var indexPath: IndexPath!
    var cell: UITableViewCell!
    var tableView: UITableView!
    
    let avatarImage = UIImageView()
    let nameLabel = UILabel()
    
    let avatarHeight: CGFloat = 40
    let likesButtonHeight: CGFloat = 30
    let likesButtonWidth: CGFloat = 100
    let menuButtonHeight: CGFloat = 20
    
    let stickerHeight: CGFloat = 150
    
    let textFont = UIFont(name: "Verdana", size: 14)!
    let nameFont = UIFont(name: "Verdana-Bold", size: 13)!
    let dateFont = UIFont(name: "Verdana", size: 11)!
    let menuFont = UIFont(name: "Verdana", size: 12)!
    
    var countButton = UIButton()
    var likesButton = UIButton()
    let commentLabel = UILabel()
    let dateLabel = UILabel()
    
    func configureCountCell(count: Int, total: Int) {
        
        self.removeAllSubviews()
        
        countButton.tag = 250
        countButton.setTitle("Показать еще \(count) из \(total) комментариев", for: .normal)
        countButton.setTitleColor(countButton.titleLabel?.tintColor, for: .normal)
        countButton.contentMode = .center
        countButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
        countButton.titleLabel?.adjustsFontSizeToFitWidth = true
        countButton.titleLabel?.minimumScaleFactor = 0.5
        countButton.frame = CGRect(x: 20, y: 0, width: cellWidth-40, height: bounds.height)
        self.addSubview(countButton)
    }
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        if let comment = comment {
            
            var topY: CGFloat = 0
            
            let maxWidth = cellWidth - avatarHeight - 40
            
            setAvatar(topY: topY)
            topY += 40
            
            topY = setText(topY: topY)
            
            let aView = AttachmentsView()
            aView.tag = 250
            aView.delegate = self.delegate
            let aHeight = aView.configureAttachView(attaches: comment.attachments, maxSize: maxWidth - 40, getRow: false)
            aView.frame = CGRect(x: avatarHeight + 40, y: topY + 10, width: maxWidth - 40, height: aHeight)
            self.addSubview(aView)
            
            topY += 10 + aHeight
            
            for attach in comment.attachments {
                if attach.type == "sticker", attach.sticker.count > 0 {
                    topY = setSticker(attach.sticker[0], topY: topY)
                }
            }
            
            for attach in comment.attachments {
                if attach.type == "doc", attach.doc.count > 0 {
                    topY = setDoc(attach.doc[0], topY: topY)
                }
            }
            
            for attach in comment.attachments {
                if attach.type == "video", attach.video.count > 0 {
                    topY = setVideo(attach.video[0], topY: topY)
                }
            }
            
            for attach in comment.attachments {
                if attach.type == "audio" && attach.audio.count > 0 {
                    topY = attachAudio(attach.audio[0], topY: topY)
                }
            }
            
            for attach in comment.attachments {
                if attach.type == "link" && attach.link.count > 0 {
                    topY = attachLink(attach.link[0], topY: topY)
                }
            }
            
            topY = setInfoPanel(topY: topY)
            
            setMenuComment(topY: topY)
        }
        
    }
    
    func setText(topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        commentLabel.tag = 250
        commentLabel.text = comment.text
        commentLabel.font = textFont
        commentLabel.numberOfLines = 0
        commentLabel.prepareTextForPublish2(delegate, cell: self)
        
        let maxWidth = cellWidth - avatarHeight - 40
        let size = delegate.getTextSize(text: commentLabel.text!, font: textFont, maxWidth: maxWidth)
        
        commentLabel.frame = CGRect(x: avatarHeight + 20, y: topY, width: maxWidth, height: size.height)
        self.addSubview(commentLabel)
        
        topY += size.height
        
        return topY
    }
    
    func setAvatar(topY: CGFloat) {
        
        var url = ""
        var name = ""
        if comment.fromID > 0 {
            if let users = self.users {
                let user = users.filter({ $0.uid == "\(comment.fromID)" })
                if user.count > 0 {
                    url = user[0].photo100
                    name = "\(user[0].firstName) \(user[0].lastName)"
                }
            }
        } else if comment.fromID < 0 {
            if let groups = self.groups {
                let group = groups.filter({ $0.gid == abs(comment.fromID) })
                if group.count > 0 {
                    url = group[0].photo100
                    name = group[0].name
                }
            }
        }
        
        
        
        avatarImage.tag = 250
        nameLabel.tag = 250
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                self.avatarImage.image = getCacheImage.outputImage
                self.avatarImage.layer.cornerRadius = self.avatarHeight/2
                self.avatarImage.clipsToBounds = true
            }
        }
        OperationQueue().addOperation(getCacheImage)
        
        nameLabel.text = name
        nameLabel.font = nameFont
        
        avatarImage.frame = CGRect(x: 10, y: topY + 10, width: avatarHeight, height: avatarHeight)
        nameLabel.frame = CGRect(x: avatarImage.frame.maxX + 10, y: topY + 10, width: cellWidth - avatarImage.frame.maxX - 20, height: 30)
        
        let tap1 = UITapGestureRecognizer()
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tap1)
        tap1.add {
            self.delegate.openProfileController(id: self.comment.fromID, name: name)
        }
        
        let tap2 = UITapGestureRecognizer()
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(tap2)
        tap2.add {
            self.delegate.openProfileController(id: self.comment.fromID, name: name)
        }
        
        self.addSubview(avatarImage)
        self.addSubview(nameLabel)
    }
    
    func setSticker(_ sticker: Sticker, topY: CGFloat) -> CGFloat {
        let photoImage = UIImageView()
        photoImage.tag = 250
        
        let getCacheImage = GetCacheImage(url: sticker.url, lifeTime: .avatarImage)
        let setImageToRow = SetImageToCommentRow(imageView: photoImage)
        setImageToRow.addDependency(getCacheImage)
        OperationQueue().addOperation(getCacheImage)
        OperationQueue.main.addOperation(setImageToRow)
        OperationQueue.main.addOperation {
            photoImage.clipsToBounds = true
        }
        
        photoImage.frame = CGRect(x: avatarHeight + 40, y: topY, width: stickerHeight, height: stickerHeight)
        self.addSubview(photoImage)
        
        return topY + stickerHeight
    }
    
    func setDoc(_ document: Document, topY: CGFloat) -> CGFloat {
        var topY = topY
        
        let maxSize = cellWidth - avatarHeight - 40
        
        if document.width > 0 && document.height > 0 {
            var photoWidth = CGFloat(document.width)
            var photoHeight = CGFloat(document.height)
            
            if photoWidth > photoHeight {
                photoWidth = maxSize - 40
                photoHeight = photoWidth * CGFloat(document.height) / CGFloat(document.width)
            } else {
                photoHeight = maxSize - 40
                photoWidth = photoHeight * CGFloat(document.width) / CGFloat(document.height)
            }
            
            let doc = UIImageView()
            doc.tag = 250
            
            if document.photoURL.count > 0 {
                let url = document.photoURL[document.photoURL.count-1]
                let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        doc.image = getCacheImage.outputImage
                        doc.clipsToBounds = true
                        doc.contentMode = .scaleToFill
                    }
                }
                OperationQueue().addOperation(getCacheImage)
            }
            
            doc.frame = CGRect(x: avatarHeight + 20 + 20, y: topY, width: photoWidth, height: photoHeight)
            self.addSubview(doc)
            
            if document.ext == "gif" && document.url != "" {
                
                let loadingView = UIView()
                loadingView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
                loadingView.center = CGPoint(x: doc.frame.width/2, y: doc.frame.height/2)
                loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
                loadingView.clipsToBounds = true
                loadingView.layer.cornerRadius = 8.5
                doc.addSubview(loadingView)
                
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.frame = CGRect(x: 0, y: 0, width: loadingView.frame.maxX, height: loadingView.frame.maxY);
                activityIndicator.activityIndicatorViewStyle = .whiteLarge
                activityIndicator.center = CGPoint(x: loadingView.frame.width/2, y: loadingView.frame.height/2)
                loadingView.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                
                let gifSizeLabel = UILabel()
                gifSizeLabel.text = "GIF: \(document.size.getFileSizeToString())"
                gifSizeLabel.numberOfLines = 1
                gifSizeLabel.font = UIFont(name: "Verdana-Bold", size: 11.0)!
                gifSizeLabel.textAlignment = .center
                gifSizeLabel.contentMode = .center
                gifSizeLabel.textColor = UIColor.black
                gifSizeLabel.backgroundColor = UIColor.lightText.withAlphaComponent(0.5)
                gifSizeLabel.layer.cornerRadius = 5
                gifSizeLabel.clipsToBounds = true
                let gifSize = delegate.getTextSize(text: gifSizeLabel.text!, font: gifSizeLabel.font!, maxWidth: doc.frame.width)
                gifSizeLabel.frame = CGRect(x: doc.frame.width - 10 - gifSize.width - 10, y: doc.frame.height - 10 - 20, width: gifSize.width + 10, height: 20)
                doc.addSubview(gifSizeLabel)
                
                OperationQueue().addOperation {
                    let url = URL(string: document.url)
                    if let data = try? Data(contentsOf: url!) {
                        let setAnimatedImageToRow = SetAnimatedImageToRow.init(data: data, imageView: doc, cell: self.cell, indexPath: self.indexPath, tableView: self.tableView)
                        setAnimatedImageToRow.completionBlock = {
                            OperationQueue.main.addOperation {
                                gifSizeLabel.removeFromSuperview()
                                activityIndicator.stopAnimating()
                                loadingView.removeFromSuperview()
                            }
                        }
                        OperationQueue.main.addOperation(setAnimatedImageToRow)
                        
                    }
                }
            }
            
            topY += photoHeight
        }
        
        return topY
    }
    
    func setVideo(_ video: Video, topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        let maxSize = cellWidth - avatarHeight - 20 - 20
            
        let videoWidth: CGFloat = maxSize - 40
        let videoHeight: CGFloat = 240 * videoWidth / 320
        
        let view = UIView()
        view.tag = 250
        view.backgroundColor = UIColor.black
        
        view.frame = CGRect(x: avatarHeight + 20 + 20, y: topY, width: videoWidth, height: videoHeight)
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
        webView.frame = CGRect(x: avatarHeight + 20 + 20, y: topY, width: videoWidth, height: videoHeight)
        
        if let controller = delegate as? WKNavigationDelegate {
            webView.navigationDelegate = controller
        }
        
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
        
        let titleLabel = UILabel()
        titleLabel.tag = 250
        titleLabel.frame = CGRect(x: avatarHeight + 20 + 20, y: webView.frame.maxY, width: videoWidth-200, height: 20)
        titleLabel.text = "\(video.title)"
        titleLabel.textColor = titleLabel.tintColor
        titleLabel.font = UIFont(name: "Verdana", size: 12)!
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        
        let tap = UITapGestureRecognizer()
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tap)
        tap.add {
            self.delegate.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись")
        }
        
        let viewsLabel = UILabel()
        viewsLabel.tag = 250
        viewsLabel.frame = CGRect(x: avatarHeight + 20 + 20 + videoWidth - 200, y: webView.frame.maxY, width: 200, height: 20)
        viewsLabel.text = "Просмотров: \(video.views.getCounterToString())"
        viewsLabel.textAlignment = .right
        viewsLabel.isEnabled = false
        viewsLabel.font = UIFont(name: "Verdana", size: 11)!
        
        self.addSubview(titleLabel)
        self.addSubview(viewsLabel)
        
        topY += videoHeight + 25
        
        return topY
    }
    
    func attachAudio(_ audio: Audio, topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        let maxSize = cellWidth - avatarHeight - 20 - 20
        
        let musicImage = UIImageView()
        musicImage.tag = 250
        
        musicImage.frame = CGRect(x: avatarHeight + 40, y: topY, width: 40, height: 40)
        musicImage.image = UIImage(named: "music")
        
        let artistLabel = UILabel()
        artistLabel.tag = 250
        artistLabel.frame = CGRect(x: avatarHeight + 40 + 50, y: musicImage.frame.midY - 16, width: maxSize - 50, height: 16)
        artistLabel.text = audio.artist
        artistLabel.font = UIFont(name: "Verdana", size: 12)!
        
        let titleLabel = UILabel()
        titleLabel.tag = 250
        titleLabel.frame = CGRect(x: avatarHeight + 40 + 50, y: musicImage.frame.midY, width: maxSize - 50, height: 16)
        titleLabel.text = audio.title
        titleLabel.textColor = titleLabel.tintColor
        titleLabel.font = UIFont(name: "Verdana", size: 12)!
        
        self.addSubview(musicImage)
        self.addSubview(artistLabel)
        self.addSubview(titleLabel)
        
        topY += 40
        
        return topY
    }
    
    func attachLink(_ link: Link, topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        let maxSize = cellWidth - avatarHeight - 20 - 20
        
        let linkImage = UIImageView()
        linkImage.tag = 250
        
        linkImage.frame = CGRect(x: avatarHeight + 40, y: topY, width: 40, height: 40)
        if link.url.containsIgnoringCase(find: "itunes.apple.com") {
            linkImage.image = UIImage(named: "itunes")
        } else {
            linkImage.image = UIImage(named: "link")
        }
        
        let titleLabel = UILabel()
        titleLabel.tag = 250
        titleLabel.frame = CGRect(x: avatarHeight + 40 + 50, y: linkImage.frame.midY - 16, width: maxSize - 50, height: 16)
        if link.title != "" {
            titleLabel.text = link.title
        } else {
            if link.caption != "" {
                titleLabel.text = link.caption
            } else {
                if link.description != "" {
                    titleLabel.text = link.description
                } else {
                    titleLabel.text = "Вложенная ссылка:"
                    titleLabel.isEnabled = false
                }
            }
        }
        titleLabel.font = UIFont(name: "Verdana", size: 12)!
        
        let linkLabel = UILabel()
        linkLabel.tag = 250
        linkLabel.frame = CGRect(x: avatarHeight + 40 + 50, y: linkImage.frame.midY, width: maxSize - 50, height: 16)
        if let url = URL(string: link.url), let host = url.host {
            linkLabel.text = host
        } else {
            linkLabel.text = link.url
        }
        linkLabel.textColor = linkLabel.tintColor
        linkLabel.font = UIFont(name: "Verdana", size: 12)!
        
        self.addSubview(linkImage)
        self.addSubview(titleLabel)
        self.addSubview(linkLabel)
        
        let tap1 = UITapGestureRecognizer()
        linkImage.isUserInteractionEnabled = true
        linkImage.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer()
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer()
        linkLabel.isUserInteractionEnabled = true
        linkLabel.addGestureRecognizer(tap3)
        
        tap1.add {
            self.delegate.openBrowserController(url: link.url)
        }
        tap2.add {
            self.delegate.openBrowserController(url: link.url)
        }
        tap3.add {
            self.delegate.openBrowserController(url: link.url)
        }
        
        topY += 40
        
        return topY
    }
    
    func setInfoPanel(topY: CGFloat) -> CGFloat {
        
        dateLabel.tag = 250
        
        let text = comment.date.toStringLastTime()
        var replyText = ""
        if comment.replyComment != 0 {
            var sex = 0
            if comment.fromID > 0 {
                let current = users.filter({ $0.uid == "\(comment.fromID)" })
                if current.count > 0 {
                    sex = current[0].sex
                }
            }
            
            if comment.replyUser > 0 {
                let users = self.users.filter({ $0.uid == "\(comment.replyUser)" })
                if users.count > 0 {
                    if sex == 1 {
                        replyText = "ответила \(users[0].firstNameDat)"
                    } else {
                        replyText = "ответил \(users[0].firstNameDat)"
                    }
                } else {
                    if sex == 1 {
                        replyText = "ответила на комментарий"
                    } else {
                        replyText = "ответил на комментарий"
                    }
                }
            } else if comment.replyUser < 0 {
                let group = groups.filter({ $0.gid == abs(comment.replyUser) })
                if group.count > 0 {
                    if sex == 1 {
                        replyText = "ответила сообществу \"\(group[0].name)\""
                    } else {
                        replyText = "ответил сообществу \"\(group[0].name)\""
                    }
                } else {
                    if sex == 1 {
                        replyText = "ответила сообществу"
                    } else {
                        replyText = "ответил сообществу"
                    }
                }
            }
        }
        
        dateLabel.text = "\(text)"
        if replyText != "" {
            dateLabel.text = "\(text) \(replyText)"
            let fullString = "\(text) \(replyText)"
            let range = (fullString as NSString).range(of: replyText)
            
            let attributedString = NSMutableAttributedString(string: fullString)
            attributedString.setAttributes([NSAttributedStringKey.foregroundColor:  dateLabel.tintColor], range: range)
            dateLabel.attributedText = attributedString
        }
        
        dateLabel.font = dateFont
        dateLabel.textAlignment = .left
        dateLabel.contentMode = .center
        dateLabel.numberOfLines = 2
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.minimumScaleFactor = 0.8
        dateLabel.contentMode = .bottom
        dateLabel.isEnabled = false
        
        dateLabel.frame = CGRect(x: avatarHeight + 20, y: topY, width: cellWidth - avatarHeight - 20 - 40 - likesButtonWidth, height: likesButtonHeight)
        self.addSubview(dateLabel)
        
        likesButton.tag = 250
        likesButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)!
        likesButton.contentHorizontalAlignment = .right
        likesButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        likesButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 10)
        
        setLikesButton(comment: comment)
        
        
        likesButton.frame = CGRect(x: cellWidth - likesButtonWidth - 20, y: topY, width: likesButtonWidth, height: likesButtonHeight)
        self.addSubview(likesButton)
        
        let tapLike = UILongPressGestureRecognizer()
        likesButton.isUserInteractionEnabled = true
        likesButton.addGestureRecognizer(tapLike)
        tapLike.add {
            self.likesButton.smallButtonTouched()
            
            self.likesButton.isEnabled = false
            self.tapLikesButton(sender: tapLike)
        }
        
        return topY + likesButtonHeight
    }
    
    func setLikesButton(comment: Comment) {
        likesButton.setTitle("\(comment.countLikes)", for: UIControlState.normal)
        likesButton.setTitle("\(comment.countLikes)", for: UIControlState.selected)
        
        if comment.userLikes == 1 {
            likesButton.setTitleColor(UIColor.purple, for: .normal)
            likesButton.setImage(UIImage(named: "like-comment")?.tint(tintColor:  UIColor.purple), for: .normal)
        } else {
            likesButton.setTitleColor(UIColor.darkGray, for: .normal)
            likesButton.setImage(UIImage(named: "like-comment")?.tint(tintColor:  UIColor.darkGray), for: .normal)
        }
    }
    
    func tapLikesButton(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            var type = "comment"
            var owner = 0
            if let vc = self.delegate as? RecordController {
                type = "comment"
                if vc.record.count > 0 {
                    owner = vc.record[0].ownerID
                }
                
                if let photo = vc.photo {
                    type = "photo_comment"
                    owner = photo.ownerID
                }
            } else if let vc = self.delegate as? VideoController {
                type = "video_comment"
                if vc.video.count > 0 {
                    owner = vc.video[0].ownerID
                }
            } else if let vc = self.delegate as? TopicController {
                type = "topic_comment"
                if vc.topics.count > 0 {
                    if let groupID = Int(vc.groupID) {
                        owner = -1 * groupID
                    }
                }
            }
            
            if comment.userLikes == 0 {
                let url = "/method/likes.add"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": type,
                    "owner_id": "\(owner)",
                    "item_id": "\(comment.id)",
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
                            self.comment.countLikes += 1
                            self.comment.userLikes = 1
                            self.setLikesButton(comment: self.comment)
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
                    "type": type,
                    "owner_id": "\(owner)",
                    "item_id": "\(comment.id)",
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
                            self.comment.countLikes -= 1
                            self.comment.userLikes = 0
                            self.setLikesButton(comment: self.comment)
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
    
    func setMenuComment(topY: CGFloat) {
        
        var leftX = avatarHeight + 20
        
        if "\(comment.fromID)" != vkSingleton.shared.userID /*&& !(self.delegate is TopicController)*/ {
            let button1 = UIButton()
            button1.tag = 250
            button1.setTitle("Ответить", for: .normal)
            button1.setTitleColor(button1.tintColor, for: .normal)
            button1.titleLabel?.font = menuFont
            button1.titleLabel?.textAlignment = .left
            button1.add(for: .touchUpInside) {
                button1.buttonTouched()
                
                let name = self.getLinkFromID(commentID: self.comment.fromID)
                
                if let controller = self.delegate as? RecordController {
                    
                    if name != "" {
                        controller.commentView.textView.text = "\(name), "
                    }
                    controller.attachPanel.replyID = self.comment.id
                    
                } else if let controller = self.delegate as? VideoController {
                    
                    if name != "" {
                        controller.commentView.textView.text = "\(name), "
                    }
                    controller.attachPanel.replyID = self.comment.id
                    
                } else if let controller = self.delegate as? TopicController {
                    
                    if name != "" {
                        controller.commentView.textView.text = "\(name), "
                    }
                    controller.attachPanel.replyID = self.comment.id
                    
                }
            }
            let size = delegate.getTextSize(text: button1.titleLabel!.text!, font: menuFont, maxWidth: cellWidth)
            button1.frame = CGRect(x: leftX, y: topY, width: size.width, height: menuButtonHeight)
            self.addSubview(button1)
            leftX += size.width + 20
        }
        
        if comment.countLikes > 0 {
            let button1 = UIButton()
            button1.tag = 250
            button1.setTitle("Кому понравилось", for: .normal)
            button1.setTitleColor(button1.tintColor, for: .normal)
            button1.titleLabel?.font = menuFont
            button1.add(for: .touchUpInside) {
                button1.buttonTouched()
                
                var type = ""
                var ownerID = ""
                
                if let controller = self.delegate as? RecordController {
                    ownerID = "\(controller.uid)"
                    
                    if controller.type == "post" {
                        type = "comment"
                    } else {
                        type = "photo_comment"
                    }
                } else if let controller = self.delegate as? VideoController {
                    ownerID = controller.ownerID
                    
                    type = "video_comment"
                } else if let controller = self.delegate as? TopicController {
                    ownerID = "-\(controller.groupID)"
                    
                    type = "topic_comment"
                }
                
                let url = "/method/likes.getList"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "type": type,
                    "owner_id": ownerID,
                    "item_id": "\(self.comment.id)",
                    "extended": "1",
                    "fields": "id, first_name, last_name, sex, has_photo, last_seen, online, photo_max_orig, photo_max, deactivated, first_name_dat, friend_status",
                    "count": "1000",
                    "skip_own": "0",
                    "v": vkSingleton.shared.version
                ]
                
                let getServerDataOperation = GetServerDataOperation(url: url, parameters: parameters)
                getServerDataOperation.completionBlock = {
                    guard let data = getServerDataOperation.data else { return }
                    
                    guard let json = try? JSON(data: data) else { print("json error"); return }
                    //print(json)
                    
                    let likes = json["response"]["items"].compactMap { Likes(json: $0.1) }
                    
                    OperationQueue.main.addOperation {
                        let likesController = self.delegate.storyboard?.instantiateViewController(withIdentifier: "LikesUsersController") as! LikesUsersController
                        
                        likesController.likes = likes
                        likesController.title = "Оценили"
                        
                        if let split = self.delegate.splitViewController {
                            let detailVC = split.viewControllers[split.viewControllers.endIndex - 1]
                            detailVC.childViewControllers[0].navigationController?.pushViewController(likesController, animated: true)
                        }
                    }
                }
                OperationQueue().addOperation(getServerDataOperation)
            }
            let size = delegate.getTextSize(text: button1.titleLabel!.text!, font: menuFont, maxWidth: cellWidth)
            button1.frame = CGRect(x: leftX, y: topY, width: size.width, height: menuButtonHeight)
            self.addSubview(button1)
            leftX += size.width + 20
        }
        
        if "\(comment.fromID)" == vkSingleton.shared.userID || (comment.fromID < 0 && vkSingleton.shared.adminGroupID.contains(abs(comment.fromID))) {
            
            if Int(Date().timeIntervalSince1970) - comment.date <= 24 * 60 * 60 {
                let button1 = UIButton()
                button1.tag = 250
                button1.setTitle("Редактировать", for: .normal)
                button1.setTitleColor(button1.tintColor, for: .normal)
                button1.titleLabel?.font = menuFont
                button1.add(for: .touchUpInside) {
                    button1.buttonTouched()
                    
                }
                let size = delegate.getTextSize(text: button1.titleLabel!.text!, font: menuFont, maxWidth: cellWidth)
                button1.frame = CGRect(x: leftX, y: topY, width: size.width, height: menuButtonHeight)
                self.addSubview(button1)
                leftX += size.width + 20
            }
            
            let button1 = UIButton()
            button1.tag = 250
            button1.setTitle("Удалить", for: .normal)
            button1.setTitleColor(UIColor.red, for: .normal)
            button1.titleLabel?.font = menuFont
            button1.add(for: .touchUpInside) {
                button1.buttonTouched()
                
                let appearance = SCLAlertView.SCLAppearance(
                    kTitleTop: 32.0,
                    kWindowWidth: 350,
                    kTitleFont: UIFont(name: "Verdana-Bold", size: 14)!,
                    kTextFont: UIFont(name: "Verdana", size: 15)!,
                    kButtonFont: UIFont(name: "Verdana", size: 16)!,
                    showCloseButton: false,
                    showCircularIcon: true
                )
                let alertView = SCLAlertView(appearance: appearance)
                
                alertView.addButton("Да, я уверен") {
                    
                    if let controller = self.delegate as? RecordController {
                        controller.deleteComment(commentID: "\(self.comment.id)")
                    } else if let controller = self.delegate as? VideoController {
                        controller.deleteComment(commentID: "\(self.comment.id)")
                    } else if let controller = self.delegate as? TopicController {
                        controller.deleteComment(commentID: "\(self.comment.id)")
                    }
                }
                
                alertView.addButton("Нет, я передумал") { }
                
                alertView.showWarning("Подтверждение!", subTitle: "Вы уверены, что хотите удалить данный комментарий? Это действие необратимо.")
            }
            
            let size = delegate.getTextSize(text: button1.titleLabel!.text!, font: menuFont, maxWidth: cellWidth)
            button1.frame = CGRect(x: leftX, y: topY, width: size.width, height: menuButtonHeight)
            self.addSubview(button1)
            leftX += size.width + 20
        }
        
        
        let button1 = UIButton()
        button1.tag = 250
        button1.setTitle("Пожаловаться", for: .normal)
        button1.setTitleColor(UIColor.red, for: .normal)
        button1.titleLabel?.font = menuFont
        button1.add(for: .touchUpInside) {
            button1.buttonTouched()
            
        }
        let size = delegate.getTextSize(text: button1.titleLabel!.text!, font: menuFont, maxWidth: cellWidth)
        button1.frame = CGRect(x: leftX, y: topY, width: size.width, height: menuButtonHeight)
        self.addSubview(button1)
    }
}



extension CommentCell {
    func getRowHeight() -> CGFloat {
        
        let height1 = 10 + avatarHeight + 10
        
        var height: CGFloat = 40
        
        let maxWidth = cellWidth - avatarHeight - 40
        
        let size = delegate.getTextSize(text: comment.text.prepareTextForPublic(), font: textFont, maxWidth: maxWidth)
        height += size.height
        
        let aView = AttachmentsView()
        height += 10 + aView.configureAttachView(attaches: comment.attachments, maxSize: maxWidth - 40, getRow: true)
        
        for attach in comment.attachments {
            if attach.type == "sticker", attach.sticker.count > 0 {
                height += stickerHeight
            }
        }
        
        for attach in comment.attachments {
            if attach.type == "doc" && attach.doc.count > 0 {
                if attach.doc[0].width > 0 && attach.doc[0].height > 0 {
                    let photoHeight = CGFloat(attach.doc[0].height)
                    let maxSize = cellWidth - avatarHeight - 40
                    
                    if CGFloat(attach.doc[0].width) > photoHeight {
                        height += (maxSize - 40) * CGFloat(attach.doc[0].height) / CGFloat(attach.doc[0].width)
                    } else {
                        height += maxSize - 40
                    }
                }
            }
        }
        for attach in comment.attachments {
            if attach.type == "video", attach.video.count > 0 {
                let maxSize = cellWidth - avatarHeight - 20 - 20
                let videoHeight = 240 * (maxSize - 40) / 320
                height += videoHeight + 25
            }
        }
        
        for attach in comment.attachments {
            if attach.type == "audio", attach.audio.count > 0 {
                height += 5
                height += 40
            }
        }
        
        for attach in comment.attachments {
            if attach.type == "link" && attach.link.count > 0 {
                height += 5
                height += 40
            }
        }
        
        height += likesButtonHeight + menuButtonHeight
        
        if height1 > height {
            return height1
        }
        
        return height
    }
    
    func getLinkFromID(commentID: Int) -> String {
        
        var link = ""
        
        if commentID > 0 {
            if let users = self.users {
                let user = users.filter({ $0.uid == "\(commentID)" })
                if user.count > 0 {
                    link = "[id\(user[0].uid)|\(user[0].firstName)]"
                }
            }
        } else if commentID < 0 {
            if let groups = self.groups {
                let group = groups.filter({ $0.gid == abs(commentID) })
                if group.count > 0 {
                    link = "[public\(group[0].gid)|\(group[0].name)]"
                }
            }
        }
        
        return link
    }
}
