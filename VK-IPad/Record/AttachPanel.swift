//
//  AttachPanel.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 02.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class AttachPanel: UIView {

    var maxAttachCount = 10
    
    var showPanel = true
    
    var delegate: UIViewController! {
        didSet {
            if !(delegate is TopicController || delegate is NewRecordController || delegate is DialogController) {
                maxAttachCount = 2
            }
        }
    }
    
    var titleGen: String {
        if delegate is NewRecordController {
            return "записи"
        } else if delegate is AddNewTopicController {
            return "обсуждению"
        } else if delegate is DialogController {
            return "сообщению"
        } else {
            return "комментарию"
        }
    }
    
    var comments: [Comment] = []
    var users: [UserProfile] = []
    var groups: [GroupProfile] = []
    
    var replyID = 0 {
        didSet {
            self.removeFromSuperview()
            self.reconfigure()
        }
    }
    
    var editID = 0
    
    var cornerRadius: CGFloat = 6
    
    var attachArray: [AnyObject] = []
    var link = ""
    var attachments = ""
    var forwards = ""
    
    var width: CGFloat = 0
    
    func reconfigure() {
        
        removeSubviews()
        self.backgroundColor = UIColor.clear
        
        var height: CGFloat = 0
        
        if width == 0 {
            width = self.delegate.view.bounds.width - 20
        }
        
        if replyID != 0 {
            let view = UIView()
            view.tag = 250
            view.backgroundColor = UIColor.white.withAlphaComponent(0.85)
            view.layer.cornerRadius = cornerRadius
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1.0
            
            let nameLabel = UILabel()
            nameLabel.tag = 250
            nameLabel.text = "Вы отвечаете \(getReplyName(commentID: replyID, label: nameLabel))"
            nameLabel.font = UIFont(name: "Verdana", size: 14)!
            nameLabel.textColor = nameLabel.tintColor
            nameLabel.frame = CGRect(x: 20, y: height, width: width - 40 - 120, height: 30)
            view.addSubview(nameLabel)
            
            
            let xButton = UIButton()
            xButton.tag = 250
            xButton.setTitle("🚫 Отменить", for: .normal)
            xButton.setTitleColor(UIColor.red, for: .normal)
            xButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
            xButton.contentHorizontalAlignment = .right
            xButton.add(for: .touchUpInside) {
                if let controller = self.delegate as? RecordController {
                    controller.commentView.textView.text = ""
                } else if let controller = self.delegate as? VideoController {
                    controller.commentView.textView.text = ""
                } else if let controller = self.delegate as? TopicController {
                    controller.commentView.textView.text = ""
                }
                self.replyID = 0
            }
            xButton.frame = CGRect(x: width - 20 - 120, y: height, width: 120, height: 30)
            if editID == 0 {
                view.addSubview(xButton)
            }
            
            view.frame = CGRect(x: 10, y: 10, width: width, height: 30)
            view.dropShadow(color: UIColor.black, opacity: 0.9, offSet: CGSize(width: -1, height: 1), radius: cornerRadius)
            self.addSubview(view)
            height += 40
        }
        
        attachments = ""
        
        if let controller = delegate as? DialogController, controller.source != .preview {
            if vkSingleton.shared.forwardMessages.count > 0 {
                forwards = vkSingleton.shared.forwardMessages.sorted().map { $0 }.joined(separator: ",")
            }
        }
        
        if attachArray.count > 0 || link != "" || forwards != "" {
            let view = UIView()
            view.tag = 250
            view.backgroundColor = UIColor.white.withAlphaComponent(0.85)
            view.layer.cornerRadius = cornerRadius
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.borderWidth = 1.0
            
            var top: CGFloat = 0
            
            var count = attachArray.count
            if link != "" {
                count += 1
            }
            if forwards != "" {
                count += 1
            }
            
            let nameLabel = UILabel()
            nameLabel.tag = 250
            nameLabel.text = "Прикрепленные к \(titleGen) вложения (\(count)):"
            nameLabel.font = UIFont(name: "Verdana", size: 14)!
            nameLabel.textColor = UIColor.purple
            nameLabel.textAlignment = .left
            nameLabel.frame = CGRect(x: 20, y: top + 5, width: width - 40 - 150, height: 20)
            view.addSubview(nameLabel)
            
            let showButton = UIButton()
            showButton.tag = 250
            if showPanel {
                showButton.setTitle("Свернуть панель", for: .normal)
            } else {
                showButton.setTitle("Развернуть панель", for: .normal)
            }
            showButton.setTitleColor(showButton.tintColor, for: .normal)
            showButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)!
            showButton.contentHorizontalAlignment = .right
            showButton.add(for: .touchUpInside) {
                self.showPanel = !self.showPanel
                self.removeFromSuperview()
                self.reconfigure()
                
                if let controller = self.delegate as? NewRecordController {
                    controller.tableView.reloadData()
                } else if let controller = self.delegate as? AddNewTopicController {
                    controller.tableView.reloadData()
                } else if let controller = self.delegate as? DialogController {
                    controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                }
            }
            showButton.frame = CGRect(x: width - 20 - 150, y: top + 5, width: 150, height: 20)
            view.addSubview(showButton)
                
            if showPanel {
                top += 25
                
                if attachArray.count > 0 {
                    for index in 0...attachArray.count-1 {
                        let imageView = UIImageView()
                        imageView.tag = 250
                        imageView.contentMode = .scaleAspectFill
                        imageView.clipsToBounds = true
                        imageView.layer.borderColor = UIColor.lightGray.cgColor
                        imageView.layer.borderWidth = 0.5
                        imageView.frame = CGRect(x: 20, y: top + 5, width: 30, height: 30)
                        view.addSubview(imageView)
                        
                        let nameLabel = UILabel()
                        nameLabel.tag = 250
                        nameLabel.font = UIFont(name: "Verdana", size: 14)!
                        nameLabel.textColor = nameLabel.tintColor
                        nameLabel.frame = CGRect(x: 60, y: top, width: width - 40 - 120, height: 40)
                        view.addSubview(nameLabel)
                        
                        let xButton = UIButton()
                        xButton.tag = 250
                        xButton.setTitle("✘ Удалить", for: .normal)
                        xButton.setTitleColor(UIColor.red, for: .normal)
                        xButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)!
                        xButton.contentHorizontalAlignment = .right
                        
                        if let video = attachArray[index] as? Video {
                            let getCacheImage = GetCacheImage(url: video.photo320, lifeTime: .userPhotoImage)
                            getCacheImage.completionBlock = {
                                OperationQueue.main.addOperation {
                                    imageView.image = getCacheImage.outputImage
                                }
                            }
                            OperationQueue().addOperation(getCacheImage)
         
                            nameLabel.text = "Видеозапись «\(video.title)»"
                            
                            let tap1 = UITapGestureRecognizer()
                            nameLabel.isUserInteractionEnabled = true
                            nameLabel.addGestureRecognizer(tap1)
                            tap1.add {
                                self.delegate.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись")
                            }
                            
                            let tap2 = UITapGestureRecognizer()
                            imageView.isUserInteractionEnabled = true
                            imageView.addGestureRecognizer(tap2)
                            tap2.add {
                                self.delegate.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись")
                            }
                        } else if let photo = attachArray[index] as? Photo {
                            let getCacheImage = GetCacheImage(url: photo.photo604, lifeTime: .userPhotoImage)
                            getCacheImage.completionBlock = {
                                OperationQueue.main.addOperation {
                                    imageView.image = getCacheImage.outputImage
                                }
                            }
                            OperationQueue().addOperation(getCacheImage)
                            
                            var text = ""
                            if photo.text != "" {
                                text = "«\(photo.text)»"
                            }
                            
                            nameLabel.text = "Фотография \(text)"
                            
                            let tap1 = UITapGestureRecognizer()
                            nameLabel.isUserInteractionEnabled = true
                            nameLabel.addGestureRecognizer(tap1)
                            tap1.add {
                                self.delegate.openWallRecord(ownerID: photo.ownerID, postID: photo.id, accessKey: photo.accessKey, type: "photo")
                            }
                            
                            let tap2 = UITapGestureRecognizer()
                            imageView.isUserInteractionEnabled = true
                            imageView.addGestureRecognizer(tap2)
                            tap2.add {
                                self.delegate.openWallRecord(ownerID: photo.ownerID, postID: photo.id, accessKey: photo.accessKey, type: "photo")
                            }
                        } else if let doc = attachArray[index] as? Document {
                            
                            if doc.type == 3 {
                                nameLabel.text = "Анимированное изображение GIF"
                                
                                var url = ""
                                if doc.photoURL.count > 0 {
                                    url = doc.photoURL[doc.photoURL.count-1]
                                }
                                
                                let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
                                getCacheImage.completionBlock = {
                                    OperationQueue.main.addOperation {
                                        imageView.image = getCacheImage.outputImage
                                    }
                                }
                                OperationQueue().addOperation(getCacheImage)
                            } else {
                                nameLabel.text = "Документ «\(doc.title)»"
                                imageView.image = UIImage(named: "document")
                            }
                            
                            let tap1 = UITapGestureRecognizer()
                            nameLabel.isUserInteractionEnabled = true
                            nameLabel.addGestureRecognizer(tap1)
                            tap1.add {
                                self.delegate.openBrowserControllerNoCheck(url: doc.url)
                            }
                            
                            let tap2 = UITapGestureRecognizer()
                            imageView.isUserInteractionEnabled = true
                            imageView.addGestureRecognizer(tap2)
                            tap2.add {
                                self.delegate.openBrowserControllerNoCheck(url: doc.url)
                            }
                        }
                        
                        xButton.add(for: .touchUpInside) {
                            self.attachArray.remove(at: index)
                            self.removeFromSuperview()
                            self.reconfigure()
                            
                            if let controller = self.delegate as? NewRecordController {
                                controller.tableView.reloadData()
                            } else if let controller = self.delegate as? AddNewTopicController {
                                controller.tableView.reloadData()
                            } else if let controller = self.delegate as? DialogController {
                                controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                            }
                        }
                        
                        xButton.frame = CGRect(x: width - 20 - 120, y: top, width: 120, height: 40)
                        view.addSubview(xButton)
                        
                        top += 40
                    }
                }
                
                if link != "" {
                    let nameLabel = UILabel()
                    nameLabel.tag = 250
                    nameLabel.text = "Внешняя ссылка:  \(link)"
                    nameLabel.font = UIFont(name: "Verdana", size: 14)!
                    nameLabel.frame = CGRect(x: 20, y: top, width: width - 40 - 120, height: 40)
                    nameLabel.prepareTextForPublish2(self.delegate, cell: nil)
                    view.addSubview(nameLabel)
                    
                    let tap1 = UITapGestureRecognizer()
                    nameLabel.isUserInteractionEnabled = true
                    nameLabel.addGestureRecognizer(tap1)
                    tap1.add {
                        self.delegate.openBrowserController(url: self.link)
                    }
                    
                    let xButton = UIButton()
                    xButton.tag = 250
                    xButton.setTitle("✘ Удалить", for: .normal)
                    xButton.setTitleColor(UIColor.red, for: .normal)
                    xButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)!
                    xButton.contentHorizontalAlignment = .right
                    
                    xButton.add(for: .touchUpInside) {
                        self.link = ""
                        self.removeFromSuperview()
                        self.reconfigure()
                        
                        if let controller = self.delegate as? NewRecordController {
                            controller.tableView.reloadData()
                        } else if let controller = self.delegate as? AddNewTopicController {
                            controller.tableView.reloadData()
                        } else if let controller = self.delegate as? DialogController {
                            controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                        }
                    }
                    
                    xButton.frame = CGRect(x: width - 20 - 120, y: top, width: 120, height: 40)
                    view.addSubview(xButton)
                    
                    top += 40
                }
                
                if forwards != "" {
                    let count = vkSingleton.shared.forwardMessages.count
                    
                    let imageView = UIImageView()
                    imageView.tag = 250
                    imageView.image = UIImage(named: "comments")
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    imageView.layer.borderColor = UIColor.lightGray.cgColor
                    imageView.layer.borderWidth = 0//0.5
                    imageView.frame = CGRect(x: 20, y: top + 5, width: 30, height: 30)
                    view.addSubview(imageView)
                    
                    let nameLabel = UILabel()
                    nameLabel.tag = 250
                    nameLabel.text = "Вложено для пересылки \(count.messageAdder())"
                    nameLabel.font = UIFont(name: "Verdana", size: 14)!
                    nameLabel.textColor = nameLabel.tintColor
                    nameLabel.frame = CGRect(x: 60, y: top, width: width - 40 - 120, height: 40)
                    nameLabel.prepareTextForPublish2(self.delegate, cell: nil)
                    view.addSubview(nameLabel)
                    
                    let tap1 = UITapGestureRecognizer()
                    nameLabel.isUserInteractionEnabled = true
                    nameLabel.addGestureRecognizer(tap1)
                    tap1.add {
                        self.delegate.openDialogController(ownerID: vkSingleton.shared.userID, startID: 0, source: .preview)
                    }
                    
                    let tap2 = UITapGestureRecognizer()
                    imageView.isUserInteractionEnabled = true
                    imageView.addGestureRecognizer(tap2)
                    tap2.add {
                        self.delegate.openDialogController(ownerID: vkSingleton.shared.userID, startID: 0, source: .preview)
                    }
                    
                    
                    let xButton = UIButton()
                    xButton.tag = 250
                    xButton.setTitle("✘ Удалить", for: .normal)
                    xButton.setTitleColor(UIColor.red, for: .normal)
                    xButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)!
                    xButton.contentHorizontalAlignment = .right
                    
                    xButton.add(for: .touchUpInside) {
                        vkSingleton.shared.forwardMessages.removeAll(keepingCapacity: false)
                        
                        self.forwards = ""
                        self.removeFromSuperview()
                        self.reconfigure()
                    }
                    
                    xButton.frame = CGRect(x: width - 20 - 120, y: top, width: 120, height: 40)
                    view.addSubview(xButton)
                    
                    top += 40
                } else {
                    forwards = ""
                }
            } else {
                top += 30
            }
            
            if attachArray.count > maxAttachCount {
                let maxLabel = UILabel()
                maxLabel.tag = 250
                maxLabel.text = "Внимание! Вы превысили максимальное количество вложений: \(maxAttachCount)"
                maxLabel.font = UIFont(name: "Verdana", size: 13)!
                maxLabel.textColor = UIColor.red
                maxLabel.textAlignment = .center
                maxLabel.frame = CGRect(x: 20, y: top + 5, width: width - 40, height: 20)
                view.addSubview(maxLabel)
                
                top += 30
            }
            
            if replyID == 0 {
                height += 10
            } else {
                height += 5
            }
            view.frame = CGRect(x: 10, y: height, width: width, height: top)
            height += top
            
            view.dropShadow(color: UIColor.black, opacity: 0.9, offSet: CGSize(width: -1, height: 1), radius: cornerRadius)
            self.addSubview(view)
        }
        
        if let controller = delegate as? RecordController {
            controller.commentView.attachCount = attachArray.count
        } else if let controller = delegate as? VideoController {
            controller.commentView.attachCount = attachArray.count
        } else if let controller = delegate as? TopicController {
            controller.commentView.attachCount = attachArray.count
        } else if let controller = delegate as? DialogController {
            controller.commentView.attachCount = attachArray.count
            if forwards != "" {
                controller.commentView.attachCount += 1
            }
        }
        
        self.frame = CGRect(x: 0, y: 64, width: width + 20, height: height)
        if height > 0 {
            self.delegate.view.addSubview(self)
        }
        
        attachments = formStringAttachments()
        print("attachments = \(attachments)")
    }
    
    func getReplyName(commentID: Int, label: UILabel) -> String {
        var name = ""
        
        if let comment = comments.filter({ $0.id == commentID }).first {
            if comment.fromID > 0 {
                if let user = users.filter({ $0.uid == "\(comment.fromID)" }).first {
                    if delegate is TopicController {
                        name = "пользователю «\(user.firstName) \(user.lastName)»"
                    } else {
                        name = "\(user.firstNameDat) \(user.lastNameDat)"
                    }
                }
            } else if comment.fromID < 0 {
                if let group = groups.filter({ $0.gid == abs(comment.fromID) }).first {
                    name = "сообществу «\(group.name)»"
                }
            }
            
            let tap = UITapGestureRecognizer()
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tap)
            tap.add {
                self.delegate.openProfileController(id: comment.fromID, name: "")
            }
        }
        
        return name
    }
    
    func removeSubviews() {
        for subview in self.subviews {
            if subview.tag == 250 {
                subview.removeFromSuperview()
            }
        }
    }
    
    func formStringAttachments() -> String {
        
        var str = ""
        
        for attach in attachArray {
            if let photo = attach as? Photo {
                if str != "" {
                    str = "\(str),"
                }
                str = "\(str)photo\(photo.ownerID)_\(photo.id)"
            }
            
            if let video = attach as? Video {
                if str != "" {
                    str = "\(str),"
                }
                str = "\(str)video\(video.ownerID)_\(video.id)"
            }
            
            if let doc = attach as? Document {
                if str != "" {
                    str = "\(str),"
                }
                str = "\(str)doc\(doc.ownerID)_\(doc.id)"
            }
        }
        
        if link != "" {
            if str != "" {
                str = "\(str),"
            }
            str = "\(str)\(link)"
        }
        return str
    }
}
