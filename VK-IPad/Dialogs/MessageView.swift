//
//  MessageView.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 27.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON

class MessageView: UIView {

    private struct Constants {
        static let bodyFont = UIFont(name: "Verdana", size: 15)!
        static let fwdFont = UIFont(name: "Verdana", size: 12)!
        static let dateFont = UIFont(name: "Verdana", size: 12)!
        
        static let inBackColor = UIColor(red: 244/255, green: 223/255, blue: 200/255, alpha: 1)
        static let outBackColor = UIColor(red: 200/255, green: 200/255, blue: 238/255, alpha: 1)
        static let fwdBackColor = UIColor(red: 234/255, green: 255/255, blue: 214/255, alpha: 1)
    }
    
    var delegate: DialogController!
    var cell: MessageCell!
    var indexPath: IndexPath!
    var dialog: Dialog!
    
    var forward = false
    
    var maxWidth: CGFloat = 0
    
    let avatarImage = UIImageView()
    let bodyView = UIView()
    
    let fwdView = UIView()
    var fwdHeight: CGFloat = 0
    
    func configureView(calcHeight: Bool) -> CGFloat {
        
        self.backgroundColor = UIColor.clear
        
        var height: CGFloat = 0
        let width: CGFloat = delegate.width
        
        
        if !calcHeight {
            var avatarURL = ""
            var avatarName = ""
            if dialog.fromID > 0 {
                let users = delegate.users.filter({ $0.uid == "\(dialog.fromID)" })
                if users.count > 0 {
                    avatarURL = users[0].maxPhotoOrigURL
                    avatarName = "\(users[0].firstName) \(users[0].lastName)"
                }
            } else if dialog.fromID < 0 {
                let groups = delegate.groups.filter({ $0.gid == abs(dialog.fromID) })
                if groups.count > 0 {
                    avatarURL = groups[0].photo100
                    avatarName = groups[0].name
                }
            }
            avatarImage.image = UIImage(named: "nophoto")
            avatarImage.contentMode = .scaleAspectFill
            
            let getCacheImage = GetCacheImage(url: avatarURL, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: delegate.tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                self.avatarImage.layer.cornerRadius = 20
                self.avatarImage.clipsToBounds = true
                self.avatarImage.contentMode = .scaleAspectFill
                self.avatarImage.layer.borderColor = UIColor.lightGray.cgColor
                self.avatarImage.layer.borderWidth = 0.5
            }
            
            if dialog.out == 0 {
                avatarImage.frame = CGRect(x: 10, y: 0, width: 40, height: 40)
            } else {
                avatarImage.frame = CGRect(x: maxWidth - 10 - 40, y: 0, width: 40, height: 40)
            }
            self.addSubview(avatarImage)
            
            let tapAvatar = UITapGestureRecognizer()
            tapAvatar.add {
                if self.delegate.mode == .dialog {
                    self.delegate.openProfileController(id: self.dialog.fromID, name: avatarName)
                }
            }
            avatarImage.isUserInteractionEnabled = true
            avatarImage.addGestureRecognizer(tapAvatar)
        }
        
        let size = delegate.getTextSize(text: dialog.body.prepareTextForPublic(), font: Constants.bodyFont, maxWidth: maxWidth)
        
        if !calcHeight && size.height > 0 {
            let label = UILabel()
            label.text = dialog.body
            label.font = Constants.bodyFont
            label.numberOfLines = 0
            label.prepareTextForPublish2(delegate, cell: cell)
            label.frame = CGRect(x: 10, y: 0, width: size.width, height: size.height + 10)
            bodyView.addSubview(label)
            
            var leftX: CGFloat = 0
            if dialog.out == 0 {
                leftX = 60
                bodyView.backgroundColor = Constants.inBackColor
            } else {
                leftX = maxWidth - 60 - (label.frame.width + 20)
                bodyView.backgroundColor = Constants.outBackColor
            }
            if forward {
                bodyView.backgroundColor = Constants.fwdBackColor
            }
            bodyView.frame = CGRect(x: leftX, y: height, width: label.frame.width + 20, height: label.frame.height)
            bodyView.configureMessageView()
            self.addSubview(bodyView)
        }
        
        if size.height > 0 {
            height += size.height + 12
        }
        
        let aView = AttachmentsView()
        aView.tag = 250
        aView.delegate = self.delegate
        let aHeight = aView.configureAttachView(attaches: dialog.attachments, maxSize: maxWidth - 60, getRow: calcHeight)
        
        if !calcHeight && aHeight > 0 {
            var leftX: CGFloat = 0
            if dialog.out == 0 {
                leftX = 60
                if !forward {
                    aView.configureViewWithPhotos(color: Constants.inBackColor)
                }
            } else {
                leftX = maxWidth - 60 - aView.frame.width
                if !forward {
                    aView.configureViewWithPhotos(color: Constants.outBackColor)
                }
            }
            if forward {
                aView.configureViewWithPhotos(color: Constants.fwdBackColor)
            }
            aView.frame = CGRect(x: leftX, y: height, width: aView.frame.width, height: aHeight)
            aView.clipsToBounds = true
            self.addSubview(aView)
        }
        
        height += aHeight + 2
        
        for attach in dialog.attachments {
            let videoHeight = setVideo(attach, maxWidth: maxWidth, topY: height, calc: calcHeight)
            if videoHeight > 0 {
                height += videoHeight + 2
            }
            
            let docHeight = setDocument(attach, maxWidth: maxWidth, topY: height, calc: calcHeight)
            if docHeight > 0 {
                height += docHeight + 2
            }
            
            let linkHeight = setLink(attach, maxWidth: maxWidth, topY: height, calc: calcHeight)
            if linkHeight > 0 {
                height += linkHeight + 2
            }
            
            let stickerHeight = setSticker(attach, maxWidth: maxWidth, topY: height, calc: calcHeight)
            height += stickerHeight
            
            if attach.record.count > 0 {
                let recordHeight = setRecord(attach.record[0], maxWidth: maxWidth, topY: height, calc: calcHeight)
                height += recordHeight + 2
            }
        }
        
        if dialog.fwdMessages.count > 0 {
            height += 12
            fwdView.tag = 250
            fwdHeight = 0
        }
        
        for dialog in self.dialog.fwdMessages {
            if !calcHeight {
                let label = UILabel()
                var avatarName = ""
                if dialog.fromID > 0 {
                    let users = delegate.users.filter({ $0.uid == "\(dialog.fromID)" })
                    if users.count > 0 {
                        avatarName = " от \(users[0].firstNameGen) \(users[0].lastNameGen)"
                    }
                } else if dialog.fromID < 0 {
                    avatarName = " от сообщества"
                }
                label.text = "Пересланное сообщение\(avatarName)"
                label.font = Constants.fwdFont
                label.numberOfLines = 1
                label.textAlignment = .right
                label.textColor = UIColor.gray
                label.frame = CGRect(x: 20, y: fwdHeight + 2, width: maxWidth - 40, height: 20)
                fwdView.addSubview(label)
            }
            fwdHeight += 25
            
            let view = MessageView()
            view.delegate = self.delegate
            view.cell = self.cell
            view.dialog = dialog
            view.maxWidth = self.maxWidth - 90
            view.indexPath = self.indexPath
            view.forward = true
            
            let fwdHeight1 = view.configureView(calcHeight: calcHeight)
            
            if !calcHeight {
                view.frame = CGRect(x: 0, y: fwdHeight, width: view.maxWidth, height: fwdHeight1)
                fwdView.addSubview(view)
            }
            
            fwdHeight += fwdHeight1
        }
        
        if dialog.fwdMessages.count > 0 {
            if !calcHeight {
                var leftX: CGFloat = 0
                if dialog.out == 0 {
                    leftX = 60
                    fwdView.backgroundColor = Constants.inBackColor
                } else {
                    leftX = width - 60 - maxWidth
                    fwdView.backgroundColor = Constants.outBackColor
                }
                fwdView.frame = CGRect(x: leftX, y: height, width: maxWidth, height: fwdHeight)
                fwdView.configureViewWithFwd()
                cell.addSubview(fwdView)
                fwdView.bringSubview(toFront: cell)
            }
            height += fwdHeight - 10
        }
        
        if !calcHeight {
            let label = UILabel()
            label.text = dialog.date.toStringLastTime()
            label.font = Constants.dateFont
            label.numberOfLines = 1
            if !forward {
                label.isEnabled = false
            } else {
                label.isEnabled = true
                label.textColor = UIColor.gray
            }
            if dialog.out == 0 {
                label.frame = CGRect(x: 63, y: height, width: maxWidth - 66, height: 16)
                label.textAlignment = .left
            } else {
                label.frame = CGRect(x: 3, y: height, width: maxWidth - 66, height: 16)
                label.textAlignment = .right
            }
            self.addSubview(label)
        }
        
        height += 20
        
        if !calcHeight {
            var leftX: CGFloat = 0
            if dialog.out == 0 {
                leftX = 0
            } else {
                leftX = width - maxWidth
            }
            
            var topY: CGFloat = 12
            if forward {
                topY = 0
            }
            
            self.frame = CGRect(x: leftX, y: topY, width: maxWidth, height: height)
            cell.addSubview(self)
            cell.bringSubview(toFront: fwdView)
        }
        
        height = max(height,60)
        if !forward {
            height += 24
        }
        
        return height
    }
    
    func setVideo(_ attach: Attachment, maxWidth: CGFloat, topY: CGFloat, calc: Bool) -> CGFloat {
        
        var height: CGFloat = 0
        
        if attach.type == "video" && attach.video.count > 0 {
            
            let videoWidth: CGFloat = maxWidth - 60
            let videoHeight: CGFloat = 240 * videoWidth / 320
            
            if !calc {
                let view = UIView()
                view.clipsToBounds = true
                
                var leftX: CGFloat = 0
                if dialog.out == 0 {
                    leftX = 60
                    view.configureViewWithVideo(color: Constants.inBackColor)
                    if !forward {
                        view.backgroundColor = Constants.inBackColor
                    }
                } else {
                    leftX = 0
                    view.configureViewWithVideo(color: Constants.outBackColor)
                    if !forward {
                        view.backgroundColor = Constants.outBackColor
                    }
                }
                if forward {
                    view.backgroundColor = Constants.fwdBackColor
                }
                view.frame = CGRect(x: leftX, y: topY, width: videoWidth, height: videoHeight + 33)
                self.addSubview(view)
                
                let loadingView = UIView()
                loadingView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
                loadingView.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2 - 10)
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
                webView.frame = CGRect(x: 0, y: 0, width: videoWidth, height: videoHeight)
                webView.navigationDelegate = delegate
                
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
                                    view.addSubview(webView)
                                }
                            }
                        }
                    }
                    OperationQueue().addOperation(getServerData)
                } else {
                    if let url = URL(string: attach.video[0].player) {
                        let request = URLRequest(url: url)
                        webView.load(request)
                        view.addSubview(webView)
                    }
                }
                
                let titleLabel = UILabel()
                titleLabel.tag = 250
                titleLabel.frame = CGRect(x: 10, y: webView.frame.maxY, width: videoWidth-20, height: 31)
                titleLabel.text = "Видеозапись: «\(attach.video[0].title)»"
                titleLabel.textColor = titleLabel.tintColor
                titleLabel.textAlignment = .center
                titleLabel.numberOfLines = 2
                titleLabel.font = UIFont(name: "Verdana", size: 13)!
                titleLabel.adjustsFontSizeToFitWidth = true
                titleLabel.minimumScaleFactor = 0.8
                
                let tap = UITapGestureRecognizer()
                titleLabel.isUserInteractionEnabled = true
                titleLabel.addGestureRecognizer(tap)
                tap.add {
                    self.delegate.openVideoController(ownerID: "\(attach.video[0].ownerID)", vid: "\(attach.video[0].id)", accessKey: attach.video[0].accessKey, title: "Видеозапись")
                }
                view.addSubview(titleLabel)
            }
            
            height = videoHeight + 33
        }
        
        return height
    }
    
    func setDocument(_ attach: Attachment, maxWidth: CGFloat, topY: CGFloat, calc: Bool) -> CGFloat {
        
        var height: CGFloat = 0
        
        if attach.type == "doc" && attach.doc.count > 0 {
            let width: CGFloat = 0.7 * maxWidth
            
            height = 5 + 20 + 30 + 20 + 5
            
            if !calc {
                let view = UIView()
                view.clipsToBounds = true
                
                let statusLabel = UILabel()
                if attach.doc[0].type == 1 {
                    statusLabel.text = "Документ: текстовый документ"
                } else if attach.doc[0].type == 2 {
                    statusLabel.text = "Документ: архив"
                } else if attach.doc[0].type == 3 {
                    statusLabel.text = "Документ: GIF"
                } else if attach.doc[0].type == 4 {
                    statusLabel.text = "Документ: фотография"
                } else if attach.doc[0].type == 5 {
                    statusLabel.text = "Документ: аудиозапись"
                } else if attach.doc[0].type == 6 {
                    statusLabel.text = "Документ: видеозапись"
                } else if attach.doc[0].type == 7 {
                    statusLabel.text = "Документ: электронная книга"
                } else {
                    statusLabel.text = "Документ: неизвестный тип"
                }
                statusLabel.textAlignment = .center
                statusLabel.font = UIFont(name: "Verdana", size: 13)!
                statusLabel.isEnabled = false
                statusLabel.frame = CGRect(x: 10, y: 5, width: width - 20, height: 20)
                view.addSubview(statusLabel)
                
                let nameLabel = UILabel()
                nameLabel.tag = 200
                nameLabel.text = attach.doc[0].title
                nameLabel.textAlignment = .center
                nameLabel.font = UIFont(name: "Verdana-Bold", size: 14)!
                nameLabel.numberOfLines = 2
                nameLabel.adjustsFontSizeToFitWidth = true
                nameLabel.minimumScaleFactor = 0.4
                nameLabel.frame = CGRect(x: 10, y: 25, width: width - 20, height: 30)
                view.addSubview(nameLabel)
                
                let loadButton = UIButton()
                loadButton.setTitle("Открыть документ", for: .normal)
                loadButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
                loadButton.frame = CGRect(x: 10, y: 55, width: width - 20, height: 20)
                loadButton.setTitleColor(loadButton.tintColor, for: .normal)
                view.addSubview(loadButton)
                
                loadButton.add(for: .touchUpInside) {
                    if self.delegate.mode == .dialog {
                        self.delegate.openBrowserControllerNoCheck(url: attach.doc[0].url)
                    }
                }
                
                var leftX: CGFloat = 0
                if dialog.out == 0 {
                    leftX = 60
                    view.configureViewWithPhotos(color: Constants.inBackColor)
                    if !forward {
                        view.backgroundColor = Constants.inBackColor
                    }
                } else {
                    leftX = maxWidth - 60 - width
                    view.configureViewWithPhotos(color: Constants.outBackColor)
                    if !forward {
                        view.backgroundColor = Constants.outBackColor
                    }
                }
                if forward {
                    view.backgroundColor = Constants.fwdBackColor
                }
                view.frame = CGRect(x: leftX, y: topY, width: width, height: height)
                view.configureViewWithDoc()
                self.addSubview(view)
            }
        }
        
        return height
    }
    
    func setLink(_ attach: Attachment, maxWidth: CGFloat, topY: CGFloat, calc: Bool) -> CGFloat {
        
        var height: CGFloat = 0
        
        if attach.type == "link" && attach.link.count > 0 {
            
            height += 50
            
            if !calc {
                let view = UIView()
                let maxSize = maxWidth
                
                let linkImage = UIImageView()
                linkImage.frame = CGRect(x: 10, y: 5, width: 40, height: 40)
                if attach.link[0].url.containsIgnoringCase(find: "itunes.apple.com") {
                    linkImage.image = UIImage(named: "itunes")
                } else {
                    linkImage.image = UIImage(named: "link")
                }
                
                let titleLabel = UILabel()
                titleLabel.frame = CGRect(x: 60, y: linkImage.frame.midY - 16, width: maxSize - 70, height: 16)
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
                linkLabel.frame = CGRect(x: 60, y: linkImage.frame.midY, width: maxSize - 70, height: 16)
                if let url = URL(string: attach.link[0].url), let host = url.host {
                    linkLabel.text = host
                } else {
                    linkLabel.text = attach.link[0].url
                }
                linkLabel.textColor = linkLabel.tintColor
                linkLabel.font = UIFont(name: "Verdana", size: 12)!
                
                view.addSubview(linkImage)
                view.addSubview(titleLabel)
                view.addSubview(linkLabel)
                
                let tapLink = UITapGestureRecognizer()
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(tapLink)
                tapLink.add {
                    self.delegate.openBrowserController(url: attach.link[0].url)
                }
                
                var leftX: CGFloat = 0
                if dialog.out == 0 {
                    leftX = 60
                    view.backgroundColor = Constants.inBackColor
                } else {
                    leftX = maxWidth - 60 - maxSize
                    view.backgroundColor = Constants.outBackColor
                }
                if forward {
                    view.backgroundColor = Constants.fwdBackColor
                }
                view.frame = CGRect(x: leftX, y: topY, width: maxSize, height: height)
                view.configureViewWithFwd()
                self.addSubview(view)
            }
        }
        
        return height
    }
    
    func setSticker(_ attach: Attachment, maxWidth: CGFloat, topY: CGFloat, calc: Bool) -> CGFloat {
        
        var height: CGFloat = 0
        
        if attach.type == "sticker" && attach.sticker.count > 0 {
            let width = 0.5 * maxWidth
            height = width * CGFloat(attach.sticker[0].height) / CGFloat(attach.sticker[0].width)
            
            if !calc {
                let photo = UIImageView()
                let getCacheImage = GetCacheImage(url: attach.sticker[0].url, lifeTime: .avatarImage)
                let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: photo, indexPath: indexPath, tableView: delegate.tableView)
                setImageToRow.addDependency(getCacheImage)
                OperationQueue().addOperation(getCacheImage)
                OperationQueue.main.addOperation(setImageToRow)
                
                var leftX: CGFloat = 0
                if dialog.out == 0 {
                    leftX = 60
                } else {
                    leftX = maxWidth - 60 - width
                }
                photo.frame = CGRect(x: leftX, y: topY, width: width, height: height)
                self.addSubview(photo)
            }
        }
        
        return height
    }
    
    func setRecord(_ record: Record, maxWidth: CGFloat, topY: CGFloat, calc: Bool) -> CGFloat {
        
        let height: CGFloat = 100
        
        if !calc {
            let view = UIView()
            view.clipsToBounds = true
            
            var url = ""
            var name = ""
            if record.fromID > 0 {
                let users = delegate.users.filter({ $0.uid == "\(record.fromID)" })
                if users.count > 0 {
                    url = users[0].maxPhotoOrigURL
                    name = "\(users[0].firstName) \(users[0].lastName)"
                }
            } else if record.fromID < 0 {
                let groups = delegate.groups.filter({ $0.gid == abs(record.fromID) })
                if groups.count > 0 {
                    url = groups[0].photo100
                    name = groups[0].name
                }
            }
            
            let avatar = UIImageView()
            avatar.image = UIImage(named: "nophoto")
            avatar.contentMode = .scaleAspectFill
            
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    avatar.image = getCacheImage.outputImage
                    avatar.layer.cornerRadius = 20
                    avatar.clipsToBounds = true
                    avatar.contentMode = .scaleAspectFill
                    avatar.layer.borderColor = UIColor.lightGray.cgColor
                    avatar.layer.borderWidth = 0.6
                }
            }
            OperationQueue().addOperation(getCacheImage)
            
            
            avatar.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
            view.addSubview(avatar)
            
            let width = 0.9 * maxWidth
            
            let nameLabel = UILabel()
            nameLabel.tag = 200
            nameLabel.text = name
            nameLabel.font = UIFont(name: "Verdana-Bold", size: 14)!
            nameLabel.adjustsFontSizeToFitWidth = true
            nameLabel.minimumScaleFactor = 0.5
            nameLabel.frame = CGRect(x: 20 + 40, y: 10, width: width - 30 - 40, height: 20)
            view.addSubview(nameLabel)
            
            let dateLabel = UILabel()
            dateLabel.text = record.date.toStringLastTime()
            dateLabel.font = UIFont(name: "Verdana", size: 11)!
            dateLabel.adjustsFontSizeToFitWidth = true
            dateLabel.minimumScaleFactor = 0.5
            dateLabel.isEnabled = false
            dateLabel.frame = CGRect(x: 20 + 40, y: 24, width: width - 30 - 30, height: 20)
            view.addSubview(dateLabel)
            
            let bodyLabel = UILabel()
            bodyLabel.tag = 200
            
            if record.text != "" {
                bodyLabel.text = record.text.prepareTextForPublic().replacingOccurrences(of: "\n", with: " ")
                bodyLabel.textAlignment = .left
                bodyLabel.isEnabled = true
            } else {
                bodyLabel.text = "... Запись на стене ..."
                bodyLabel.textAlignment = .center
                bodyLabel.isEnabled = false
            }
            
            bodyLabel.font = UIFont(name: "Verdana", size: 13)!
            bodyLabel.textColor = UIColor.black
            bodyLabel.numberOfLines = 2
            bodyLabel.frame = CGRect(x: 15, y: 20 + 40, width: width - 30, height: 35)
            view.addSubview(bodyLabel)
            
            var leftX: CGFloat = 0
            if dialog.out == 0 {
                leftX = 60
                if !forward {
                    view.backgroundColor = Constants.inBackColor
                }
            } else {
                leftX = maxWidth - 60 - width
                if !forward {
                    view.backgroundColor = Constants.outBackColor
                }
            }
            if forward {
                view.backgroundColor = Constants.fwdBackColor
            }
            view.frame = CGRect(x: leftX, y: topY, width: width, height: height)
            view.configureViewWithDoc()
            self.addSubview(view)
            
            let tap = UITapGestureRecognizer()
            tap.add {
                if self.delegate.mode == .dialog {
                    self.delegate.openWallRecord(ownerID: record.fromID, postID: record.id, accessKey: "", type: "post")
                }
            }
            tap.numberOfTapsRequired = 1
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(tap)
        }
        
        return height
    }
}

extension UIView {
    
    func configureMessageView() {
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 6
    }
    
    func configureViewWithPhotos(color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 4
        self.layer.cornerRadius = 6
    }
    
    func configureViewWithVideo(color: UIColor) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 4
        self.layer.cornerRadius = 6
    }
    
    func configureViewWithDoc() {
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 6
    }
    
    func configureViewWithFwd() {
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 6
    }
}
