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
        static let dateFont = UIFont(name: "Verdana", size: 12)!
        
        static let inBackColor = UIColor(red: 244/255, green: 223/255, blue: 200/255, alpha: 1)
        static let outBackColor = UIColor(red: 200/255, green: 200/255, blue: 238/255, alpha: 1)
    }
    
    var delegate: DialogController!
    var cell: MessageCell!
    var indexPath: IndexPath!
    var dialog: Dialog!
    
    var maxWidth: CGFloat = 0
    
    let bodyView = UIView()
    
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
            let avatarImage = UIImageView()
            avatarImage.tag = 250
            let getCacheImage = GetCacheImage(url: avatarURL, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: delegate.tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                avatarImage.layer.cornerRadius = 20
                avatarImage.clipsToBounds = true
                avatarImage.contentMode = .scaleAspectFill
                avatarImage.layer.borderColor = UIColor.lightGray.cgColor
                avatarImage.layer.borderWidth = 0.5
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
                aView.configureViewWithPhotos(color: Constants.inBackColor)
            } else {
                leftX = maxWidth - 60 - aView.frame.width
                aView.configureViewWithPhotos(color: Constants.outBackColor)
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
            
            let stickerHeight = setSticker(attach, maxWidth: maxWidth, topY: height, calc: calcHeight)
            height += stickerHeight
            
            if attach.record.count > 0 {
                let recordHeight = setRecord(attach.record[0], maxWidth: maxWidth, topY: height, calc: calcHeight)
                height += recordHeight
            }
        }
        
        if !calcHeight {
            let label = UILabel()
            label.text = dialog.date.toStringLastTime()
            label.font = Constants.dateFont
            label.numberOfLines = 1
            label.isEnabled = false
            if dialog.out == 0 {
                label.frame = CGRect(x: 63, y: height, width: maxWidth - 66, height: 20)
                label.textAlignment = .left
            } else {
                label.frame = CGRect(x: 3, y: height, width: maxWidth - 66, height: 20)
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
            self.frame = CGRect(x: leftX, y: 12, width: maxWidth, height: height)
            cell.addSubview(self)
        }
        
        height = max(height,60)
        return height + 24
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
                    view.backgroundColor = Constants.inBackColor
                } else {
                    leftX = 0
                    view.configureViewWithVideo(color: Constants.outBackColor)
                    view.backgroundColor = Constants.outBackColor
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
                    view.backgroundColor = Constants.inBackColor
                } else {
                    leftX = maxWidth - 60 - width
                    view.configureViewWithPhotos(color: Constants.outBackColor)
                    view.backgroundColor = Constants.outBackColor
                }
                view.frame = CGRect(x: leftX, y: topY, width: width, height: height)
                view.configureViewWithDoc()
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
                view.backgroundColor = Constants.inBackColor
            } else {
                leftX = maxWidth - 60 - width
                view.backgroundColor = Constants.outBackColor
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
}
