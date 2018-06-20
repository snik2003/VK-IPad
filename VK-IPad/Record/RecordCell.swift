//
//  RecordCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 15.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import FLAnimatedImage

class RecordCell: UITableViewCell {
    
    var delegate: UIViewController!
    var record: Record!
    var users: [UserProfile]!
    var groups: [GroupProfile]!
    
    var showLikesPanel = false
    
    var indexPath: IndexPath!
    var cell: UITableViewCell!
    var tableView: UITableView!
    
    var cellWidth: CGFloat = 0
    var leftX: CGFloat = 20
    
    let avatarHeight: CGFloat = 50
    let avatarHeight2: CGFloat = 40
    
    var answerLabels: [UILabel] = []
    var rateLabels: [UILabel] = []
    var totalLabel = UILabel()
    
    let friendsOnlyLabel = UILabel()
    
    let textFont = UIFont(name: "Verdana", size: 13)!
    let nameFont = UIFont(name: "Verdana-Bold", size: 13)!
    let qLabelFont = UIFont(name: "Verdana-Bold", size: 13)!
    let aLabelFont = UIFont(name: "Verdana", size: 12)!
    
    let likesHeight: CGFloat = 35
    
    var likesButton = UIButton()
    var repostsButton = UIButton()
    var commentsButton = UIButton()
    var viewsButton = UIButton()
    
    var poll: Poll!
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        answerLabels.removeAll(keepingCapacity: false)
        rateLabels.removeAll(keepingCapacity: false)
        
        if let record = record {
            
            //collectionView.delegate = self
            
            var topY: CGFloat = 0
            leftX = 20
            let maxWidth = cellWidth - leftX - 20
            setOnlyFriends()
            
            setHeader(topY: topY, size: avatarHeight, record: record)
            
            topY += 5 + avatarHeight + 5
            topY = setText(text: record.text, topY: topY)
            
            let aView = AttachmentsView()
            aView.tag = 250
            let aHeight = aView.configureAttachView(attaches: record.attachments, maxSize: maxWidth - 40, getRow: false)
            aView.frame = CGRect(x: leftX + 20, y: topY, width: maxWidth - 40, height: aHeight)
            self.addSubview(aView)
            
            topY += aHeight
            topY -= 5
            for attach in record.attachments {
                if attach.type == "doc" {
                    topY += 5
                    topY = setDoc(attach, topY: topY)
                }
            }
            
            for attach in record.attachments {
                if attach.type == "video" {
                    topY += 5
                    topY = setVideo(attach, topY: topY)
                }
            }
            
            for attach in record.attachments {
                if attach.type == "poll" && attach.poll.count > 0 {
                    topY += 5
                    self.poll = attach.poll[0]
                    topY = configurePoll(self.poll, topY: topY)
                }
            }
            
            for attach in record.attachments {
                if attach.type == "audio" && attach.audio.count > 0 {
                    topY += 5
                    topY = attachAudio(attach, topY: topY)
                }
            }
            
            for attach in record.attachments {
                if attach.type == "link" && attach.link.count > 0 {
                    topY += 5
                    topY = attachLink(attach, topY: topY)
                }
            }
            topY += 5
            
            if record.copy.count > 0 {
                for index in 0...record.copy.count-1 {
                    let x1 = topY
                    
                    leftX += 20
                    let maxWidth2 = cellWidth - leftX - 20
                    setHeader(topY: topY, size: avatarHeight2, record: record.copy[index])
                    
                    topY += 5 + avatarHeight2 + 5
                    topY = setText(text: record.copy[index].text.prepareTextForPublic(), topY: topY)
                    
                    let aView = AttachmentsView()
                    aView.tag = 250
                    let aHeight = aView.configureAttachView(attaches: record.copy[index].attachments, maxSize: maxWidth2 - 40, getRow: false)
                    aView.frame = CGRect(x: leftX + 20, y: topY, width: maxWidth2 - 40, height: aHeight)
                    self.addSubview(aView)
                    
                    topY += aHeight
                    topY -= 5
                    for attach in record.copy[index].attachments {
                        if attach.type == "doc" {
                            topY += 5
                            topY = setDoc(attach, topY: topY)
                        }
                    }
                    
                    for attach in record.copy[index].attachments {
                        if attach.type == "video" {
                            topY += 5
                            topY = setVideo(attach, topY: topY)
                        }
                    }
                    
                    for attach in record.copy[index].attachments {
                        if attach.type == "poll" && attach.poll.count > 0 {
                            topY += 5
                            self.poll = attach.poll[0]
                            topY = configurePoll(self.poll, topY: topY)
                        }
                    }
                    
                    for attach in record.copy[index].attachments {
                        if attach.type == "audio" && attach.audio.count > 0 {
                            topY += 5
                            topY = attachAudio(attach, topY: topY)
                        }
                    }
                    
                    for attach in record.copy[index].attachments {
                        if attach.type == "link" && attach.link.count > 0 {
                            topY += 5
                            topY = attachLink(attach, topY: topY)
                        }
                    }
                    topY += 5
                    
                    topY = setSigner(record: record.copy[index], topY: topY)
                    
                    let x2 = topY
                    drawRepostLine(x1, x2)
                }
            }
            
            leftX = 20
            
            topY = setSigner(record: record, topY: topY)
            topY += 5
            
            setSeparator(inView: self, topY: topY)
            topY = setLikesPanel(topY: topY)
        }
    }
        
    
    func setOnlyFriends() {
        
        if let record = self.record {
            if record.friendsOnly == 1 {
                let friendsOnlyLabel = UILabel()
                
                friendsOnlyLabel.tag = 250
                friendsOnlyLabel.text = "Запись только для друзей!"
                friendsOnlyLabel.textAlignment = .right
                friendsOnlyLabel.font = UIFont(name: "Verdana", size: 11)!
                friendsOnlyLabel.textColor = UIColor.red
                
                friendsOnlyLabel.frame = CGRect(x: cellWidth - 170, y: 2, width: 150, height: 18)
                
                self.addSubview(friendsOnlyLabel)
            }
        }
    }
    
    func setHeader(topY: CGFloat, size: CGFloat, record: Record) {

        var url = ""
        var name = ""
        
        let avatarImage = UIImageView()
        let nameLabel = UILabel()
        let dateLabel = UILabel()
        
        avatarImage.tag = 250
        nameLabel.tag = 250
        dateLabel.tag = 250
        
        if record.fromID > 0 {
            let user = users.filter({ $0.uid == "\(record.fromID)" })
            if user.count > 0 {
                url = user[0].photo100
                name = "\(user[0].firstName) \(user[0].lastName)"
            }
        } else if record.fromID < 0 {
            let group = groups.filter({ $0.gid == abs(record.fromID) })
            if group.count > 0 {
                url = group[0].photo100
                name = group[0].name
            }
        }
        
        let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
        getCacheImage.completionBlock = {
            OperationQueue.main.addOperation {
                avatarImage.image = getCacheImage.outputImage
                avatarImage.layer.cornerRadius = size/2
                avatarImage.clipsToBounds = true
            }
        }
        OperationQueue().addOperation(getCacheImage)
        
        nameLabel.text = name
        if record.isPinned == 1 {
            nameLabel.text = "📌 \(name)"
        }
        nameLabel.font = nameFont
        
        if record.postType == "postpone" {
            dateLabel.text = "⏱ \(record.date.toStringLastTime())"
        } else {
            dateLabel.text = record.date.toStringLastTime()
            if record.sourcePlatform != "" {
                dateLabel.setSourceOfRecord(text: " \(dateLabel.text!)", source: record.sourcePlatform, delegate: delegate)
            }
        }
        dateLabel.font = UIFont(name: "Verdana", size: 11)!
        dateLabel.isEnabled = false
        
        avatarImage.frame = CGRect(x: leftX - 10, y: topY + 5, width: size, height: size)
        nameLabel.frame = CGRect(x: avatarImage.frame.maxX + 10, y: avatarImage.frame.midY - 20, width: cellWidth - avatarImage.frame.maxX - 20, height: 20)
        dateLabel.frame = CGRect(x: avatarImage.frame.maxX + 10, y: avatarImage.frame.midY, width: cellWidth - avatarImage.frame.maxX - 20, height: 16)
        
        let tap1 = UITapGestureRecognizer()
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tap1)
        tap1.add {
            self.delegate.openProfileController(id: record.fromID, name: name)
        }
        
        let tap2 = UITapGestureRecognizer()
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(tap2)
        tap2.add {
            self.delegate.openProfileController(id: record.fromID, name: name)
        }
        
        let tap3 = UITapGestureRecognizer()
        dateLabel.isUserInteractionEnabled = true
        dateLabel.addGestureRecognizer(tap3)
        tap3.add {
            self.delegate.openProfileController(id: record.fromID, name: name)
        }
        
        self.addSubview(avatarImage)
        self.addSubview(nameLabel)
        self.addSubview(dateLabel)
    }
    
    func setText(text: String, topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        let label = UILabel()
        
        label.tag = 250
        label.text = text
        label.font = textFont
        label.numberOfLines = 0
        label.prepareTextForPublish2(delegate)
        
        let maxWidth = cellWidth - leftX - 20
        var size = delegate.getTextSize(text: label.text!, font: textFont, maxWidth: maxWidth)
        
        if size.height > 0 {
            size.height += 10
        }
        
        label.frame = CGRect(x: leftX, y: topY, width: maxWidth, height: size.height)
        self.addSubview(label)
        
        topY += size.height
        
        return topY
    }
    
    func setDoc(_ attach: Attachment, topY: CGFloat) -> CGFloat {
    
        var topY = topY
        
        let maxSize = cellWidth - leftX - 20
        
        if attach.type == "doc" && attach.doc.count > 0 {
            if attach.doc[0].width > 0 && attach.doc[0].height > 0 {
                var photoWidth = CGFloat(attach.doc[0].width)
                var photoHeight = CGFloat(attach.doc[0].height)
                
                if photoWidth > photoHeight {
                    photoWidth = maxSize - 40
                    photoHeight = photoWidth * CGFloat(attach.doc[0].height) / CGFloat(attach.doc[0].width)
                } else {
                    photoHeight = maxSize - 40
                    photoWidth = photoHeight * CGFloat(attach.doc[0].width) / CGFloat(attach.doc[0].height)
                }
                
                let doc = UIImageView()
                doc.tag = 250
                
                if attach.doc[0].photoURL.count > 0 {
                    let url = attach.doc[0].photoURL[attach.doc[0].photoURL.count-1]
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
                
                doc.frame = CGRect(x: leftX + 20, y: topY, width: photoWidth, height: photoHeight)
                self.addSubview(doc)
                
                if attach.doc[0].ext == "gif" && attach.doc[0].url != "" {
                    
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
                    gifSizeLabel.text = "GIF: \(attach.doc[0].size.getFileSizeToString())"
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
                        let url = URL(string: attach.doc[0].url)
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
        }
        
        return topY
    }
    
    func setVideo(_ attach: Attachment, topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        let maxSize = cellWidth - leftX - 20
        
        if attach.type == "video" && attach.video.count > 0 {
            
            let videoWidth: CGFloat = maxSize - 40
            let videoHeight: CGFloat = 240 * videoWidth / 320
            
            let view = UIView()
            view.tag = 250
            view.backgroundColor = UIColor.black
            
            view.frame = CGRect(x: leftX + 20, y: topY, width: videoWidth, height: videoHeight)
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
            webView.frame = CGRect(x: leftX + 20, y: topY, width: videoWidth, height: videoHeight)
            
            if let controller = delegate as? WKNavigationDelegate {
                webView.navigationDelegate = controller
            }
            
            if attach.video[0].player == "" {
                let url = "/method/video.get"
                let parameters = [
                    "access_token": vkSingleton.shared.accessToken,
                    "owner_id": "\(attach.video[0].ownerID)",
                    "videos": "\(attach.video[0].ownerID)_\(attach.video[0].id)_\(attach.video[0].accessKey)",
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
                if let url = URL(string: attach.video[0].player) {
                    let request = URLRequest(url: url)
                    webView.load(request)
                    self.addSubview(webView)
                }
            }
            
            let titleLabel = UILabel()
            titleLabel.tag = 250
            titleLabel.frame = CGRect(x: leftX + 20, y: webView.frame.maxY, width: videoWidth-200, height: 20)
            titleLabel.text = "\(attach.video[0].title)"
            titleLabel.textColor = titleLabel.tintColor
            titleLabel.font = UIFont(name: "Verdana", size: 12)!
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.8
            
            let viewsLabel = UILabel()
            viewsLabel.tag = 250
            viewsLabel.frame = CGRect(x: leftX + 20 + videoWidth - 200, y: webView.frame.maxY, width: 200, height: 20)
            viewsLabel.text = "Просмотров: \(attach.video[0].views.getCounterToString())"
            viewsLabel.textAlignment = .right
            viewsLabel.isEnabled = false
            viewsLabel.font = UIFont(name: "Verdana", size: 11)!
            
            self.addSubview(titleLabel)
            self.addSubview(viewsLabel)
            
            topY += videoHeight + 25
        }
        
        return topY
    }
    
    func attachAudio(_ attach: Attachment, topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        let maxSize = cellWidth - leftX - 20
        
        let musicImage = UIImageView()
        musicImage.tag = 250
        
        musicImage.frame = CGRect(x: leftX, y: topY, width: 40, height: 40)
        musicImage.image = UIImage(named: "music")
        
        let artistLabel = UILabel()
        artistLabel.tag = 250
        artistLabel.frame = CGRect(x: leftX + 50, y: musicImage.frame.midY - 16, width: maxSize - 50, height: 16)
        artistLabel.text = attach.audio[0].artist
        artistLabel.font = UIFont(name: "Verdana", size: 12)!
        
        let titleLabel = UILabel()
        titleLabel.tag = 250
        titleLabel.frame = CGRect(x: leftX + 50, y: musicImage.frame.midY, width: maxSize - 50, height: 16)
        titleLabel.text = attach.audio[0].title
        titleLabel.textColor = titleLabel.tintColor
        titleLabel.font = UIFont(name: "Verdana", size: 12)!
        
        self.addSubview(musicImage)
        self.addSubview(artistLabel)
        self.addSubview(titleLabel)
        
        topY += 40
        
        return topY
    }
    
    func attachLink(_ attach: Attachment, topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        let maxSize = cellWidth - leftX - 20
        
        let linkImage = UIImageView()
        linkImage.tag = 250
        
        linkImage.frame = CGRect(x: leftX, y: topY, width: 40, height: 40)
        if attach.link[0].url.containsIgnoringCase(find: "itunes.apple.com") {
            linkImage.image = UIImage(named: "itunes")
        } else {
            linkImage.image = UIImage(named: "link")
        }
        
        let titleLabel = UILabel()
        titleLabel.tag = 250
        titleLabel.frame = CGRect(x: leftX + 50, y: linkImage.frame.midY - 16, width: maxSize - 50, height: 16)
        if attach.link[0].title != "" {
            titleLabel.text = attach.link[0].title
        } else {
            if attach.link[0].caption != "" {
                titleLabel.text = attach.link[0].caption
            } else {
                if attach.link[0].description != "" {
                    titleLabel.text = attach.link[0].description
                } else {
                    titleLabel.text = "Вложенная ссылка:"
                    titleLabel.isEnabled = false
                }
            }
        }
        titleLabel.font = UIFont(name: "Verdana", size: 12)!
        
        let linkLabel = UILabel()
        linkLabel.tag = 250
        linkLabel.frame = CGRect(x: leftX + 50, y: linkImage.frame.midY, width: maxSize - 50, height: 16)
        if let url = URL(string: attach.link[0].url), let host = url.host {
            linkLabel.text = host
        } else {
            linkLabel.text = attach.link[0].url
        }
        linkLabel.textColor = linkLabel.tintColor
        linkLabel.font = UIFont(name: "Verdana", size: 12)!
        
        self.addSubview(linkImage)
        self.addSubview(titleLabel)
        self.addSubview(linkLabel)
        
        topY += 40
        
        return topY
    }
    
    func configurePoll(_ poll: Poll, topY: CGFloat) -> CGFloat {
        
        let view = UIView()
        view.tag = 250
        
        var viewY: CGFloat = 5
        let width = cellWidth - leftX - 20 - 40
        
        let qLabel = UILabel()
        qLabel.font = qLabelFont
        qLabel.text = "Опрос: \(poll.question)"
        qLabel.textAlignment = .center
        qLabel.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        qLabel.textColor = UIColor.white
        qLabel.numberOfLines = 0
        
        let qLabelSize = delegate.getTextSize(text: "Опрос: \(poll.question)", font: qLabelFont, maxWidth: width - 10)
        
        qLabel.frame = CGRect(x: 5, y: viewY, width: width - 10, height: qLabelSize.height + 5)
        view.addSubview(qLabel)
        
        if poll.anonymous == 1 {
            let anonLabel = UILabel()
            anonLabel.text = "Анонимный опрос"
            anonLabel.textAlignment = .right
            anonLabel.isEnabled = false
            anonLabel.font = UIFont(name: "Verdana", size: 10)!
            anonLabel.frame = CGRect(x: 10, y: viewY + qLabelSize.height + 5, width: width - 20, height: 15)
            view.addSubview(anonLabel)
        }
        viewY += qLabelSize.height + 25
        
        
        for index in 0...poll.answers.count-1 {
            let aLabel = UILabel()
            aLabel.font = aLabelFont
            aLabel.text = "\(index+1). \(poll.answers[index].text)"
            aLabel.textColor = UIColor.black
            aLabel.numberOfLines = 0
            aLabel.tag = index
            
            let aLabelSize = delegate.getTextSize(text: "\(index+1). \(poll.answers[index].text)", font: aLabelFont, maxWidth: width - 10)
            aLabel.frame = CGRect(x: 5, y: viewY, width: width - 10, height: aLabelSize.height + 5)
            view.addSubview(aLabel)
            
            viewY += aLabelSize.height
            
            let rLabel = UILabel()
            rLabel.text = ""
            rLabel.textAlignment = .right
            rLabel.textColor = UIColor.clear
            rLabel.font = UIFont(name: "Verdana-Bold", size: 10)!
            rLabel.frame = CGRect(x: 5, y: viewY+5, width: width - 10, height: 15)
            view.addSubview(rLabel)
            rateLabels.append(rLabel)
            
            let tap = UITapGestureRecognizer()
            tap.add {
                self.pollVote(sender: aLabel)
            }
            aLabel.isUserInteractionEnabled = true
            aLabel.addGestureRecognizer(tap)
            
            viewY += 25
            answerLabels.append(aLabel)
        }
        
        totalLabel.font = UIFont(name: "Verdana-Bold", size: 11)!
        totalLabel.textAlignment = .right
        totalLabel.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        totalLabel.isEnabled = true
        totalLabel.numberOfLines = 1
        
        totalLabel.frame = CGRect(x: 20, y: viewY, width: width - 40, height: 20)
        view.addSubview(totalLabel)
        viewY += 20
        
        view.frame = CGRect(x: leftX + 20, y: topY, width: width, height: viewY)
        view.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
        view.layer.borderWidth = 1.0
        self.addSubview(view)
        
        updatePoll()
        
        return topY + viewY + 10
    }
    
    func updatePoll() {
        for index in 0...answerLabels.count-1 {
            rateLabels[index].text = "\(self.poll.answers[index].votes.rateAdder()) (\(self.poll.answers[index].rate) %)"
            
            if self.poll.answerID != 0 {
                rateLabels[index].textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
                answerLabels[index].backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
                if self.poll.answerID == self.poll.answers[index].id {
                    answerLabels[index].backgroundColor = UIColor.purple.withAlphaComponent(0.75)
                    answerLabels[index].textColor = UIColor.white
                }
            } else {
                rateLabels[index].textColor = UIColor.clear
                answerLabels[index].backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 0.5)
                answerLabels[index].textColor = UIColor.black
            }
        }
        totalLabel.text = "Всего проголосовало: \(self.poll.votes)"
    }
    
    func drawRepostLine(_ x1: CGFloat, _ x2: CGFloat) {
        
        let view = UIView()
        
        view.tag = 250
        view.backgroundColor = UIColor.lightGray
        view.frame = CGRect(x: leftX - 20, y: x1, width: 2, height: x2 - x1)
        view.layer.cornerRadius = 0.5
        view.clipsToBounds = true
        
        self.addSubview(view)
    }
    
    func setSigner(record: Record, topY: CGFloat) -> CGFloat {
        
        var topY = topY
        let maxSize = cellWidth - leftX - 20
        
        if record.signerID > 0 {
            let user = users.filter({ $0.uid == "\(record.signerID)" })
            if user.count > 0 {
                let signerLabel = UILabel()
                signerLabel.tag = 250
                signerLabel.text = "\(user[0].firstName) \(user[0].lastName)"
                signerLabel.textAlignment = .right
                signerLabel.textColor = signerLabel.tintColor
                
                signerLabel.frame = CGRect(x: leftX, y: topY, width: maxSize, height: 25)
                self.addSubview(signerLabel)
                
                let tap = UITapGestureRecognizer()
                signerLabel.isUserInteractionEnabled = true
                signerLabel.addGestureRecognizer(tap)
                tap.add {
                    self.delegate.openProfileController(id: record.signerID, name: signerLabel.text!)
                }
            }
            topY += 25
        }
        
        return topY
    }
    
    func setLikesPanel(topY: CGFloat) -> CGFloat {
        
        var topY = topY
        let maxWidth = cellWidth - leftX - 20
        
        if showLikesPanel {
            let buttonWidth = maxWidth / 5
            
            likesButton.tag = 250
            likesButton.frame = CGRect(x: leftX, y: topY, width: buttonWidth, height: likesHeight)
            likesButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
            likesButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
            likesButton.contentVerticalAlignment = .center
            
            setLikesButton()
            
            self.addSubview(likesButton)
            
            likesButton.add(for: .touchUpInside) {
                self.likesButton.smallButtonTouched()
            }
            
            repostsButton.tag = 250
            repostsButton.frame = CGRect(x: leftX + buttonWidth, y: topY, width: buttonWidth, height: likesHeight)
            repostsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
            repostsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            repostsButton.contentVerticalAlignment = .center
            
            repostsButton.setTitle("\(record.repostCount)", for: UIControlState.normal)
            repostsButton.setTitle("\(record.repostCount)", for: UIControlState.selected)
            repostsButton.setImage(UIImage(named: "repost"), for: .normal)
            repostsButton.imageView?.tintColor = UIColor.black
            repostsButton.setTitleColor(UIColor.black, for: .normal)
            if record.userReposted == 1 {
                repostsButton.setTitleColor(UIColor.purple, for: .normal)
                repostsButton.imageView?.tintColor = UIColor.purple
            }
            
            self.addSubview(repostsButton)
            
            repostsButton.add(for: .touchUpInside) {
                self.repostsButton.smallButtonTouched()
            }
            
            commentsButton.tag = 250
            commentsButton.frame = CGRect(x: leftX + 3 * buttonWidth, y: topY, width: buttonWidth, height: likesHeight)
            commentsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
            commentsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
            commentsButton.contentVerticalAlignment = .center
            
            commentsButton.setImage(UIImage(named: "comments"), for: .normal)
            commentsButton.setTitleColor(UIColor.init(red: 124/255, green: 172/255, blue: 238/255, alpha: 1), for: .normal)
            
            commentsButton.setTitle("\(record.commentsCount)", for: UIControlState.normal)
            commentsButton.setTitle("\(record.commentsCount)", for: UIControlState.selected)
            
            self.addSubview(commentsButton)
            
            commentsButton.add(for: .touchUpInside) {
                self.commentsButton.smallButtonTouched()
            }
            
            viewsButton.tag = 250
            viewsButton.frame = CGRect(x: leftX + 4 * buttonWidth, y: topY, width: buttonWidth, height: likesHeight)
            viewsButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 13)!
            viewsButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
            viewsButton.contentVerticalAlignment = .center
            
            viewsButton.setTitle("\(record.viewsCount.getCounterToString())", for: UIControlState.normal)
            viewsButton.setTitle("\(record.viewsCount.getCounterToString())", for: UIControlState.selected)
            viewsButton.setImage(UIImage(named: "views"), for: .normal)
            viewsButton.setTitleColor(UIColor.darkGray, for: .normal)
            viewsButton.isEnabled = false
            
            self.addSubview(viewsButton)
            
            topY += likesHeight
        }
        return topY
    }
    
    func setLikesButton() {
        likesButton.setTitle("\(record.likesCount)", for: UIControlState.normal)
        likesButton.setTitle("\(record.likesCount)", for: UIControlState.selected)
        
        if record.userLikes == 1 {
            likesButton.setTitleColor(UIColor.purple, for: .normal)
            likesButton.setImage(UIImage(named: "like")?.tint(tintColor:  UIColor.purple), for: .normal)
        } else {
            likesButton.setTitleColor(UIColor.darkGray, for: .normal)
            likesButton.setImage(UIImage(named: "like")?.tint(tintColor:  UIColor.darkGray), for: .normal)
        }
    }
}

extension RecordCell {
    func getRowHeight() -> CGFloat {
        
        var height = 5 + avatarHeight + 5
        var leftX: CGFloat = 20

        let maxWidth = cellWidth - leftX - 20
        var size = delegate.getTextSize(text: record.text.prepareTextForPublic(), font: textFont, maxWidth: maxWidth)
        
        if size.height > 0 {
            size.height += 10
        }
        height += size.height
        
        let aView = AttachmentsView()
        height += aView.configureAttachView(attaches: record.attachments, maxSize: maxWidth - 40, getRow: true)
        
        height -= 5
        for attach in record.attachments {
            if attach.type == "doc" && attach.doc.count > 0 {
                height += 5
                if attach.doc[0].width > 0 && attach.doc[0].height > 0 {
                    let photoHeight = CGFloat(attach.doc[0].height)
                    
                    if CGFloat(attach.doc[0].width) > photoHeight {
                        height += (maxWidth - 40) * CGFloat(attach.doc[0].height) / CGFloat(attach.doc[0].width)
                    } else {
                        height += maxWidth - 40
                    }
                }
            }
            
            if attach.type == "video" && attach.video.count > 0 {
                height += 5
                let videoWidth: CGFloat = maxWidth - 40
                let videoHeight: CGFloat = 240 * videoWidth / 320
                
                height += videoHeight + 25
            }
            
            if attach.type == "audio" && attach.audio.count > 0 {
                height += 5
                height += 40
            }
            
            if attach.type == "link" && attach.link.count > 0 {
                height += 5
                height += 40
            }
            
            if attach.type == "poll" && attach.poll.count > 0 {
                height += 5
                
                let poll = attach.poll[0]
                let qLabelSize = delegate.getTextSize(text: "Опрос: \(poll.question)", font: qLabelFont, maxWidth: maxWidth)
                var viewY: CGFloat = 5 + qLabelSize.height + 25
                
                for ind in 0...poll.answers.count-1 {
                    let aLabelSize = delegate.getTextSize(text: "\(ind+1). \(poll.answers[ind].text)", font: aLabelFont, maxWidth: maxWidth)
                    viewY += aLabelSize.height + 25
                }
                
                viewY += 20
                height += viewY + 10
            }
        }
        height += 5
        
        if record.copy.count > 0 {
            for index in 0...record.copy.count-1 {
                leftX += 20
            
                height += 5 + avatarHeight2 + 5
                
                let maxWidth2 = cellWidth - leftX - 20
                var size2 = delegate.getTextSize(text: record.copy[index].text.prepareTextForPublic(), font: textFont, maxWidth: maxWidth2)
                
                if size2.height > 0 {
                    size2.height += 10
                }
                height += size2.height
                
                let aView = AttachmentsView()
                height += aView.configureAttachView(attaches: record.copy[index].attachments, maxSize: maxWidth2 - 40, getRow: true)
                
                height -= 5
                for attach in record.copy[index].attachments {
                    if attach.type == "doc" && attach.doc.count > 0 {
                        height += 5
                        if attach.doc[0].width > 0 && attach.doc[0].height > 0 {
                            let photoHeight = CGFloat(attach.doc[0].height)
                            let maxSize = cellWidth - leftX - 20
                            
                            if CGFloat(attach.doc[0].width) > photoHeight {
                                height += (maxSize - 40) * CGFloat(attach.doc[0].height) / CGFloat(attach.doc[0].width)
                            } else {
                                height += maxSize - 40
                            }
                        }
                    }
                    
                    if attach.type == "video" && attach.video.count > 0 {
                        height += 5
                        let videoWidth: CGFloat = maxWidth2 - 40
                        let videoHeight: CGFloat = 240 * videoWidth / 320
                        
                        height += videoHeight + 25
                    }
                    
                    if attach.type == "audio" && attach.audio.count > 0 {
                        height += 5
                        height += 40
                    }
                    
                    if attach.type == "link" && attach.link.count > 0 {
                        height += 5
                        height += 40
                    }
                    
                    if attach.type == "poll" && attach.poll.count > 0 {
                        height += 5
                        
                        let poll = attach.poll[0]
                        let qLabelSize = delegate.getTextSize(text: "Опрос: \(poll.question)", font: qLabelFont, maxWidth: maxWidth)
                        var viewY: CGFloat = 5 + qLabelSize.height + 25
                        
                        for ind in 0...poll.answers.count-1 {
                            let aLabelSize = delegate.getTextSize(text: "\(ind+1). \(poll.answers[ind].text)", font: aLabelFont, maxWidth: maxWidth)
                            viewY += aLabelSize.height + 25
                        }
                        
                        viewY += 20
                        height += viewY + 10
                    }
                }
                height += 5
                
                if record.copy[index].signerID > 0 {
                    height += 25
                }
            }
        }
        
        if record.signerID > 0 {
            height += 25
        }
        
        height += 5
        
        if showLikesPanel {
            height += likesHeight
        }
        
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
    
    func pollVote(sender: UILabel) {
        let num = sender.tag
        
        if let poll = self.poll {
            if poll.answerID == 0 {
                
                let alertController = UIAlertController(title: "Вы выбрали следующий вариант:", message: "\(num+1). \(poll.answers[num].text)", preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action = UIAlertAction(title: "Отдать свой голос", style: .default) { action in
                    let url = "/method/polls.addVote"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": "\(poll.ownerID)",
                        "poll_id": "\(poll.id)",
                        "answer_id": "\(poll.answers[num].id)",
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
                                poll.votes += 1
                                poll.answers[num].votes += 1
                                for answer in poll.answers {
                                    answer.rate = Int(Double(answer.votes) / Double(poll.votes) * 100)
                                }
                                poll.answerID = poll.answers[num].id
                                self.updatePoll()
                            }
                        } else if error.errorCode == 250 {
                            self.delegate.showErrorMessage(title: "Голосование по опросу!", msg: "Нет доступа к опросу.")
                        } else if error.errorCode == 251 {
                            self.delegate.showErrorMessage(title: "Голосование по опросу!", msg: "Недопустимый идентификатор опроса.")
                        } else if error.errorCode == 252 {
                            self.delegate.showErrorMessage(title: "Голосование по опросу!", msg: "Недопустимый идентификатор ответа. ")
                        } else {
                            self.delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action)
                
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.delegate.view
                    popoverController.sourceRect = CGRect(x: self.delegate.view.bounds.midX, y: self.delegate.view.bounds.maxY - 100, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                delegate.present(alertController, animated: true)
            } else {
            
                var message = ""
                for index in 0...poll.answers.count-1 {
                    if poll.answers[index].id == poll.answerID {
                        message = "\(index+1). \(poll.answers[index].text)"
                    }
                }
                
                let alertController = UIAlertController(title: "Вы проголосовали за вариант:", message: message, preferredStyle: .actionSheet)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                alertController.addAction(cancelAction)
                
                let action = UIAlertAction(title: "Отозвать свой голос", style: .destructive) { action in
                    let url = "/method/polls.deleteVote"
                    let parameters = [
                        "access_token": vkSingleton.shared.accessToken,
                        "owner_id": "\(poll.ownerID)",
                        "poll_id": "\(poll.id)",
                        "answer_id": "\(poll.answerID)",
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
                                poll.votes -= 1
                                poll.answers[num].votes -= 1
                                for answer in poll.answers {
                                    answer.rate = Int(Double(answer.votes) / Double(poll.votes) * 100)
                                }
                                poll.answerID = 0
                                self.updatePoll()
                            }
                        } else if error.errorCode == 250 {
                            self.delegate.showErrorMessage(title: "Голосование по опросу!", msg: "Нет доступа к опросу.")
                        } else if error.errorCode == 251 {
                            self.delegate.showErrorMessage(title: "Голосование по опросу!", msg: "Недопустимый идентификатор опроса.")
                        } else if error.errorCode == 252 {
                            self.delegate.showErrorMessage(title: "Голосование по опросу!", msg: "Недопустимый идентификатор ответа. ")
                        } else {
                            self.delegate.showErrorMessage(title: "Ошибка #\(error.errorCode)", msg: "\n\(error.errorMsg)\n")
                        }
                    }
                    
                    OperationQueue().addOperation(request)
                }
                alertController.addAction(action)
                
                if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.delegate.view
                    popoverController.sourceRect = CGRect(x: self.delegate.view.bounds.midX, y: self.delegate.view.bounds.maxY - 100, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                delegate.present(alertController, animated: true)
            }
        }
    }
}
