//
//  NotificationCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 12.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    var delegate: NotificationController!
    
    var not: Notification!
    var users: [UserProfile]!
    var groups: [GroupProfile]!
    
    var indexPath: IndexPath!
    var cell: UITableViewCell!
    var tableView: UITableView!
    
    var notLabel = UILabel()
    
    var cellWidth: CGFloat = 0
    
    var avatarHeight: CGFloat = 60
    var smallAvatarHeight: CGFloat = 30
    var leftInsets: CGFloat = 10
    var topInsets: CGFloat = 10
    
    var textFont = UIFont(name: "Verdana", size: 15)!
    var dateFont = UIFont(name: "Verdana", size: 12)!
    
    let linkColor = UIColor.init(red: 20/255, green: 120/255, blue: 246/255, alpha: 1)
    let parentColor = UIColor.brown
    let feedbackColor = UIColor.purple
    
    var notText = ""
    var name = ""
    
    var postString = ""
    var parentString = ""
    var feedbackString = ""
    
    func configureCell(calc: Bool) -> CGFloat {
        
        if calc == false {
            self.removeAllSubviews()
        }
        
        
        var notID = 0
        var url = ""
        var sex = -1
        var smallAvatarName = "error"
        var typeGroup = "в группу"
        var nameGroup = ""
        
        if not.feedback.count > 0, let row = indexPath?.row {
            notID = not.feedback[row].fromID
            if notID > 0 {
                let user = users.filter({ $0.uid == "\(notID)" })
                if user.count > 0 {
                    url = user[0].photo100
                    sex = user[0].sex
                    name = "\(user[0].firstName) \(user[0].lastName)"
                }
                
                if not.type == "group_invite" {
                    if not.feedback[row].type == "page" {
                        typeGroup = "в сообщество"
                    } else if not.feedback[indexPath.row].type == "event" {
                        typeGroup = "на мероприятие"
                    }
                    
                    nameGroup = "«\(not.feedback[row].text)»"
                }
            } else {
                let group = groups.filter({ $0.gid == abs(notID) })
                if group.count > 0 {
                    url = group[0].photo100
                    name = group[0].name
                }
            }
        }
        
        if not.type == "group_invite" {
            smallAvatarName = "not_invite"
                
            if sex == 1 {
                notText = "\(name) пригласила вас \(typeGroup) \(nameGroup)"
            } else {
                notText = "\(name) пригласил вас \(typeGroup) \(nameGroup)"
            }
        
            postString = typeGroup
            parentString = nameGroup
            feedbackString = ""
        }
        
        if not.type == "follow" || not.type == "friend_accepted" {
            smallAvatarName = "not_plus"
            
            if not.type == "follow" {
                if sex == 1 {
                    notText = "\(name) подписалась на Вас"
                } else {
                    notText = "\(name) подписался на Вас"
                }
            }
            
            if not.type == "friend_accepted" {
                if sex == 1 {
                    notText = "\(name) приняла вашу заявку в друзья"
                } else {
                    notText = "\(name) принял вашу заявку в друзья"
                }
            }
        }
        
        if not.type == "wall" {
            smallAvatarName = "not_plus"
            
            if sex == 1 {
                notText = "\(name) опубликовала запись \(getFeedbackNameRecord())на вашей стене"
            } else {
                notText = "\(name) опубликовал запись \(getFeedbackNameRecord())на вашей стене"
            }
            
            postString = "запись"
            parentString = getFeedbackNameRecord()
        }
        
        if not.type == "comment_post" || not.type == "comment_photo" || not.type == "comment_video" || not.type == "reply_comment" || not.type == "reply_comment_photo" || not.type == "reply_comment_video" {
            smallAvatarName = "not_comment"
            
            if not.type == "comment_post" {
                if sex == -1 {
                    notText = "Сообщество \(name) оставило комментарий \(getFeedbackCommentText()) к вашей записи \(getNameRecord())"
                } else if sex == 1 {
                    notText = "\(name) оставила комментарий \(getFeedbackCommentText()) к вашей записи \(getNameRecord())"
                } else {
                    notText = "\(name) оставил комментарий \(getFeedbackCommentText()) к вашей записи \(getNameRecord())"
                }
                
                postString = "записи"
                parentString = getNameRecord()
                feedbackString = getFeedbackCommentText()
            }
            
            if not.type == "comment_photo" {
                if sex == -1 {
                    notText = "Сообщество \(name) оставило комментарий \(getFeedbackCommentText()) к вашей фотографии \(getPhotoText())"
                } else if sex == 1 {
                    notText = "\(name) оставила комментарий \(getFeedbackCommentText()) к вашей фотографии \(getPhotoText())"
                } else {
                    notText = "\(name) оставил комментарий \(getFeedbackCommentText()) к вашей фотографии \(getPhotoText())"
                }
                
                postString = "фотографии"
                parentString = getPhotoText()
                feedbackString = getFeedbackCommentText()
            }
            
            if not.type == "comment_video" {
                if sex == -1 {
                    notText = "Сообщество \(name) оставило комментарий \(getFeedbackCommentText()) к вашей видеозаписи \(getVideoName())"
                } else if sex == 1 {
                    notText = "\(name) оставила комментарий \(getFeedbackCommentText()) к вашей видеозаписи \(getVideoName())"
                } else {
                    notText = "\(name) оставил комментарий \(getFeedbackCommentText()) к вашей видеозаписи \(getVideoName())"
                }
                
                postString = "видеозаписи"
                parentString = getVideoName()
                feedbackString = getFeedbackCommentText()
            }
            
            if not.type == "reply_comment" {
                if sex == -1 {
                    notText = "Сообщество \(name) ответило \(getFeedbackCommentText()) на ваш комментарий \(getParentCommentText()) к записи"
                } else if sex == 1 {
                    notText = "\(name) ответила \(getFeedbackCommentText()) на ваш комментарий \(getParentCommentText()) к записи"
                } else {
                    notText = "\(name) ответил \(getFeedbackCommentText()) на ваш комментарий \(getParentCommentText()) к записи"
                }
                
                postString = "записи"
                parentString = getParentCommentText()
                feedbackString = getFeedbackCommentText()
            }
            
            if not.type == "reply_comment_photo" {
                if sex == -1 {
                    notText = "Сообщество \(name) ответило \(getFeedbackCommentText()) на ваш комментарий \(getParentCommentText()) к фотографии"
                } else if sex == 1 {
                    notText = "\(name) ответила \(getFeedbackCommentText()) на ваш комментарий \(getParentCommentText()) к фотографии"
                } else {
                    notText = "\(name) ответил \(getFeedbackCommentText()) на ваш комментарий \(getParentCommentText()) к фотографии"
                }
                
                postString = "фотографии"
                parentString = getParentCommentText()
                feedbackString = getFeedbackCommentText()
            }
            
            if not.type == "reply_comment_video" {
                if sex == -1 {
                    notText = "Сообщество \(name) ответило \(getFeedbackCommentText()) на ваш комментарий \(getParentCommentText()) к видеозаписи"
                } else if sex == 1 {
                    notText = "\(name) ответила \(getFeedbackCommentText()) на ваш комментарий \(getParentCommentText()) к видеозаписи"
                } else {
                    notText = "\(name) ответил \(getFeedbackCommentText()) на ваш комментарий \(getParentCommentText()) к видеозаписи"
                }
                
                postString = "видеозаписи"
                parentString = getParentCommentText()
                feedbackString = getFeedbackCommentText()
            }
        }
        
        if not.type == "like_post" || not.type == "like_comment" || not.type == "like_photo" || not.type == "like_video" || not.type == "like_comment_photo" || not.type == "like_comment_video" || not.type == "like_comment_topic" {
            smallAvatarName = "not_like"
            
            if not.type == "like_post" {
                if indexPath.row == 0 {
                    if sex == 1 {
                        notText = "\(name) оценила вашу запись \(getNameRecord())"
                    } else {
                        notText = "\(name) оценил вашу запись \(getNameRecord())"
                    }
                    
                    postString = "запись"
                    parentString = getNameRecord()
                } else {
                    if sex == 1 {
                        notText = "\(name) также оценила эту запись"
                    } else {
                        notText = "\(name) также оценил эту запись"
                    }
                    
                    postString = ""
                    parentString = ""
                    feedbackString = ""
                }
            }
            
            if not.type == "like_photo" {
                if indexPath.row == 0 {
                    if sex == 1 {
                        notText = "\(name) оценила вашу фотографию \(getPhotoText())"
                    } else {
                        notText = "\(name) оценил вашу фотографию \(getPhotoText())"
                    }
                    
                    postString = "фотографию"
                    parentString = getPhotoText()
                } else {
                    if sex == 1 {
                        notText = "\(name) также оценила эту фотографию"
                    } else {
                        notText = "\(name) также оценил эту фотографию"
                    }
                    
                    postString = ""
                    parentString = ""
                    feedbackString = ""
                }
            }
            
            if not.type == "like_video" {
                if indexPath.row == 0 {
                    if sex == 1 {
                        notText = "\(name) оценила вашу видеозапись \(getVideoName())"
                    } else {
                        notText = "\(name) оценил вашу видеозапись \(getVideoName())"
                    }
                    
                    postString = "видеозапись"
                    parentString = getVideoName()
                } else {
                    if sex == 1 {
                        notText = "\(name) также оценила эту видеозапись"
                    } else {
                        notText = "\(name) также оценил эту видеозапись"
                    }
                    
                    postString = ""
                    parentString = ""
                    feedbackString = ""
                }
            }
            
            if not.type == "like_comment" {
                if indexPath.row == 0 {
                    if sex == 1 {
                        notText = "\(name) оценила ваш комментарий \(getParentCommentText()) к записи \(getNameRecord())"
                    } else {
                        notText = "\(name) оценил ваш комментарий \(getParentCommentText()) к записи \(getNameRecord())"
                    }
                    
                    postString = "записи"
                    parentString = getNameRecord()
                    feedbackString = getParentCommentText()
                } else {
                    if sex == 1 {
                        notText = "\(name) также оценила этот комментарий"
                    } else {
                        notText = "\(name) также оценил этот комментарий"
                    }
                    
                    postString = ""
                    parentString = ""
                    feedbackString = ""
                }
            }
            
            if not.type == "like_comment_photo" {
                if indexPath.row == 0 {
                    if sex == 1 {
                        notText = "\(name) оценила ваш комментарий \(getParentCommentText()) к фотографии \(getPhotoText())"
                    } else {
                        notText = "\(name) оценил ваш комментарий \(getParentCommentText()) к фотографии \(getPhotoText())"
                    }
                    
                    postString = "фотографии"
                    parentString = getPhotoText()
                    feedbackString = getParentCommentText()
                } else {
                    if sex == 1 {
                        notText = "\(name) также оценила этот комментарий к фотографии"
                    } else {
                        notText = "\(name) также оценил этот комментарий к фотографии"
                    }
                    
                    postString = ""
                    parentString = ""
                    feedbackString = ""
                }
            }
            
            if not.type == "like_comment_video" {
                if indexPath.row == 0 {
                    if sex == 1 {
                        notText = "\(name) оценила ваш комментарий \(getParentCommentText()) к видеозаписи \(getVideoName())"
                    } else {
                        notText = "\(name) оценил ваш комментарий \(getParentCommentText()) к видеозаписи \(getVideoName())"
                    }
                    
                    postString = "видеозаписи"
                    parentString = getVideoName()
                    feedbackString = getParentCommentText()
                } else {
                    if sex == 1 {
                        notText = "\(name) также оценила этот комментарий к видеозаписи"
                    } else {
                        notText = "\(name) также оценил этот комментарий к видеозаписи"
                    }
                    
                    postString = ""
                    parentString = ""
                    feedbackString = ""
                }
            }
        }
        
        if not.type == "copy_post" || not.type == "copy_photo" || not.type == "copy_video" {
            smallAvatarName = "not_repost"
            
            if not.type == "copy_post" {
                if indexPath.row == 0 {
                    if sex == -1 {
                        notText = "Сообщество \(name) поделилось вашей записью \(getNameRecord())на своей стене"
                    } else if sex == 1 {
                        notText = "\(name) поделилась вашей записью \(getNameRecord())на своей стене"
                    } else {
                        notText = "\(name) поделился вашей записью \(getNameRecord())на своей стене"
                    }
                    
                    postString = "записью"
                    parentString = getNameRecord()
                } else {
                    if sex == -1 {
                        notText = "Сообщество \(name) также поделилось этой записью на своей стене"
                    } else if sex == 1 {
                        notText = "\(name) также поделилась этой записью на своей стене"
                    } else {
                        notText = "\(name) также поделился этой записью на своей стене"
                    }
                    
                    postString = ""
                    parentString = ""
                    feedbackString = ""
                }
            }
            
            if not.type == "copy_photo" {
                if indexPath.row == 0 {
                    if sex == -1 {
                        notText = "Сообщество \(name) поделилось вашей фотографией \(getPhotoText())на своей стене"
                    } else if sex == 1 {
                        notText = "\(name) поделилась вашей фотографией \(getPhotoText())на своей стене"
                    } else {
                        notText = "\(name) поделился вашей фотографией \(getPhotoText())на своей стене"
                    }
                    
                    postString = "фотографией"
                    parentString = getPhotoText()
                } else {
                    if sex == -1 {
                        notText = "Сообщество \(name) также поделилось этой фотографией на своей стене"
                    } else if sex == 1 {
                        notText = "\(name) также поделилась этой фотографией на своей стене"
                    } else {
                        notText = "\(name) также поделился этой фотографией на своей стене"
                    }
                    
                    postString = ""
                    parentString = ""
                    feedbackString = ""
                }
            }
            
            if not.type == "copy_video" {
                if indexPath.row == 0 {
                    if sex == -1 {
                        notText = "Сообщество \(name) поделилось вашей видеозаписью \(getVideoName())на своей стене"
                    } else if sex == 1 {
                        notText = "\(name) поделилась вашей видеозаписью \(getVideoName())на своей стене"
                    } else {
                        notText = "\(name) поделился вашей видеозаписью \(getVideoName())на своей стене"
                    }
                    
                    postString = "видеозаписью"
                    parentString = getVideoName()
                } else {
                    if sex == -1 {
                        notText = "Сообщество \(name) также поделилось этой видеозаписью на своей стене"
                    } else if sex == 1 {
                        notText = "\(name) также поделилась этой видеозаписью на своей стене"
                    } else {
                        notText = "\(name) также поделился этой видеозаписью на своей стене"
                    }
                    
                    postString = ""
                    parentString = ""
                    feedbackString = ""
                }
            }
        }
        
        if not.type == "mention" || not.type == "mention_comments" || not.type == "mention_comment_photo" || not.type == "mention_comment_video" {
            smallAvatarName = "not_mention"
            
            if not.type == "mention" {
                if sex == -1 {
                    notText = "Сообщество \(name) упоминуло вас в записи \(getFeedbackNameRecord())на своей стене"
                } else if sex == 1 {
                    notText = "\(name) упоминула вас в записи \(getFeedbackNameRecord())на своей стене"
                } else {
                    notText = "\(name) упоминул вас в записи \(getFeedbackNameRecord())на своей стене"
                }
                
                postString = "записи"
                parentString = getFeedbackNameRecord()
            }
            
            if not.type == "mention_comments" {
                if sex == -1 {
                    notText = "Сообщество \(name) упоминуло вас в своем комментарии \(getParentCommentText()) к записи \(getNameRecord())"
                } else if sex == 1 {
                    notText = "\(name) упоминула вас в своем комментарии \(getParentCommentText()) к записи \(getNameRecord())"
                } else {
                    notText = "\(name) упоминул вас в своем комментарии \(getParentCommentText()) к записи \(getNameRecord())"
                }
                
                postString = "записи"
                parentString = getParentCommentText()
                feedbackString = getNameRecord()
            }
            
            if not.type == "mention_comment_photo" {
                if sex == -1 {
                    notText = "Сообщество \(name) упоминуло вас в комментарии \(getParentCommentText()) к фотографии \(getPhotoText())"
                } else if sex == 1 {
                    notText = "\(name) упоминула вас в комментарии \(getParentCommentText()) к фотографии \(getPhotoText())"
                } else {
                    notText = "\(name) упоминул вас в комментарии \(getParentCommentText()) к фотографии \(getPhotoText())"
                }
                
                postString = "фотографии"
                parentString = getParentCommentText()
                feedbackString = getPhotoText()
            }
            
            if not.type == "mention_comment_video" {
                if sex == -1 {
                    notText = "Сообщество \(name) упоминуло вас в комментарии \(getParentCommentText()) к видеозаписи \(getVideoName())"
                } else if sex == 1 {
                    notText = "\(name) упоминула вас в комментарии \(getParentCommentText()) к видеозаписи \(getVideoName())"
                } else {
                    notText = "\(name) упоминул вас в комментарии \(getParentCommentText()) к видеозаписи \(getVideoName())"
                }
                
                postString = "видеозаписи"
                parentString = getParentCommentText()
                feedbackString = getVideoName()
            }
        }
        
        var leftX: CGFloat = 0
        var topY: CGFloat = topInsets
        if indexPath.row > 0 {
            leftX = 50
            avatarHeight = 45
            smallAvatarHeight = 22.5
            topInsets = 3
        } else {
            leftX = 0
            topY = 25
            avatarHeight = 60
            smallAvatarHeight = 30
            topInsets = 10
        }
        
        if not.type == "group_invite" {
            topY = topInsets
        }
        
        let maxWidth = cellWidth - 3 * leftInsets - avatarHeight - leftX
        
        var size = self.delegate.getTextSize(text: notText, font: textFont, maxWidth: maxWidth)
        if size.height < avatarHeight - topY + topInsets {
            size.height = avatarHeight - topY + topInsets
        }
        
        if calc == false {
            if indexPath.section != 0 && indexPath.row == 0 {
                let separator = UIView()
                separator.tag = 250
                separator.frame = CGRect(x: leftInsets, y: 0, width: cellWidth - 2 * leftInsets, height: 1.2)
                separator.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.8)
                self.addSubview(separator)
            }
            
            let avatarImage = UIImageView()
            let smallImage = UIImageView()
            avatarImage.tag = 250
            smallImage.tag = 250
        
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            let setImageToRow = SetImageToRowOfTableView(cell: cell, imageView: avatarImage, indexPath: indexPath, tableView: tableView)
            setImageToRow.addDependency(getCacheImage)
            OperationQueue().addOperation(getCacheImage)
            OperationQueue.main.addOperation(setImageToRow)
            OperationQueue.main.addOperation {
                avatarImage.layer.cornerRadius = self.avatarHeight/2
                avatarImage.clipsToBounds = true
                smallImage.image = UIImage(named: smallAvatarName)
                smallImage.layer.cornerRadius = self.smallAvatarHeight/2
                smallImage.layer.borderColor = UIColor.white.cgColor
                smallImage.layer.borderWidth = 3.0
                smallImage.clipsToBounds = true
            }
            
            avatarImage.frame = CGRect(x: leftX + leftInsets, y: topInsets, width: avatarHeight, height: avatarHeight)
            
            smallImage.frame = CGRect(x: leftX + 2 * leftInsets + avatarHeight - smallAvatarHeight, y: topInsets + avatarHeight - smallAvatarHeight, width: smallAvatarHeight, height: smallAvatarHeight)
            
            let tapAvatar1 = UITapGestureRecognizer()
            avatarImage.isUserInteractionEnabled = true
            tapAvatar1.add {
                self.delegate.openProfileController(id: notID, name: self.name)
            }
            avatarImage.addGestureRecognizer(tapAvatar1)
            
            let tapAvatar2 = UITapGestureRecognizer()
            smallImage.isUserInteractionEnabled = true
            tapAvatar2.add {
                self.delegate.openProfileController(id: notID, name: self.name)
            }
            smallImage.addGestureRecognizer(tapAvatar2)
            
            self.addSubview(avatarImage)
            self.addSubview(smallImage)
            
            if indexPath.row == 0 && not.type != "group_invite" {
                let dateLabel = UILabel()
                dateLabel.tag = 250
                dateLabel.font = dateFont
                dateLabel.numberOfLines = 1
                dateLabel.isEnabled = false
                dateLabel.text = not.date.toStringLastTime()
                dateLabel.contentMode = .center
                dateLabel.textAlignment = .left
                
                dateLabel.frame = CGRect(x: leftX + 3 * leftInsets + avatarHeight, y: 0, width: maxWidth, height: 25)
                self.addSubview(dateLabel)
                topY = 25
            }
            
            notLabel.tag = 250
            notLabel.text = notText
            notLabel.font = textFont
            notLabel.numberOfLines = 0
            notLabel.contentMode = .top
            
            notLabel.frame = CGRect(x: leftX + 3 * leftInsets + avatarHeight, y: topY, width: size.width, height: size.height)
            self.addSubview(notLabel)
            
            setColorText(label: notLabel)
        }
        
        return topY + size.height + topInsets
    }
    
    func getParentCommentText() -> String {
        
        var str = ""
        if let comment = not.parent.comment {
            if comment.text != "" {
                str = "\"\(comment.text.prepareTextForPublic())\""
            }
        }
        
        return str
    }
    
    func getFeedbackCommentText() -> String {
        
        var str = ""
        if not.feedback.count > 0 {
            let text = not.feedback[0].text
            if text != "" {
                str = "\"\(text.prepareTextForPublic())\""
            }
        }
        
        return str
    }
    
    func getPhotoText() -> String {
        
        var str = ""
        if let photo = not.parent.photo {
            if photo.text != "" {
                str = "\"\(photo.text.prepareTextForPublic())\" "
            }
        }
        
        return str
    }
    
    func getVideoName() -> String {
        
        var str = ""
        if let video = not.parent.video {
            if video.title != "" {
                str = "\"\(video.title.prepareTextForPublic())\" "
            }
        }
        
        return str
    }
    
    func getNameRecord() -> String {
        var nameRecord = ""
        
        if let record = not.parent.post {
            var str = record.text.prepareTextForPublic()
            if record.text == "" && record.copy.count > 0 {
                str = "\(record.copy[0].text.prepareTextForPublic())"
            }
            var str1 = str.components(separatedBy: [".", "!", "?", "\n"])
            
            
            if str1[0] != "" {
                nameRecord = "\"\(str1[0])...\" "
            }
        }
        
        return nameRecord
    }
    
    func getFeedbackNameRecord() -> String {
        var nameRecord = ""
        
        let str = not.feedback[0].text.prepareTextForPublic()
        var str1 = str.components(separatedBy: [".", "!", "?", "\n"])
        
        
        if str1[0] != "" {
            nameRecord = "\"\(str1[0])...\" "
        }
        
        return nameRecord
    }
    
    func setColorText(label: UILabel) {
        
        let range1 = (notText as NSString).range(of: postString)
        let range2 = (notText as NSString).range(of: parentString)
        let range3 = (notText as NSString).range(of: feedbackString)
        
        let attributedString = NSMutableAttributedString(string: notText)
        
        attributedString.setAttributes([NSAttributedStringKey.foregroundColor: linkColor, NSAttributedStringKey.font: textFont], range: range1)
        attributedString.addAttributes([NSAttributedStringKey.foregroundColor: parentColor, NSAttributedStringKey.font: textFont], range: range2)
        attributedString.addAttributes([NSAttributedStringKey.foregroundColor: feedbackColor, NSAttributedStringKey.font: textFont], range: range3)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.add {
            if self.postString.hasPrefix("запис") {
                if let post = self.not.parent.post {
                    self.delegate.openWallRecord(ownerID: post.fromID, postID: post.id, accessKey: "", type: "post")
                } else if self.not.type == "wall" {
                    self.delegate.openWallRecord(ownerID: self.not.feedback[0].toID, postID: self.not.feedback[0].id, accessKey: "", type: "post")
                } else if self.not.type == "mention" {
                    self.delegate.openWallRecord(ownerID: self.not.feedback[0].fromID, postID: self.not.feedback[0].id, accessKey: "", type: "post")
                }
            } else if self.postString.hasPrefix("фото") {
                if let photo = self.not.parent.photo {
                    self.delegate.openPhotoViewController(numPhoto: 0, photos: [photo])
                }
            } else if self.postString.hasPrefix("видео") {
                if let video = self.not.parent.video {
                    self.delegate.openVideoController(ownerID: "\(video.ownerID)", vid: "\(video.id)", accessKey: video.accessKey, title: "Видеозапись")
                }
            } else if self.not.type == "group_invite" {
                self.delegate.openProfileController(id: -1 * self.not.feedback[0].id, name: "")
            }
        }
        
        label.attributedText = attributedString
        label.addGestureRecognizer(tapRecognizer)
        label.isUserInteractionEnabled = true
    }
}
