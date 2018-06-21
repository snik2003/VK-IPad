//
//  CommentCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 21.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    var delegate: UIViewController!
    
    var comment: Comment!
    var users: [UserProfile]!
    var groups: [GroupProfile]!
    
    var cellWidth: CGFloat = 0
    
    let avatarHeight: CGFloat = 40
    let likesButtonHeight: CGFloat = 30
    let likesButtonWidth: CGFloat = 100
    
    let textFont = UIFont(name: "Verdana", size: 12)!
    let nameFont = UIFont(name: "Verdana-Bold", size: 12)!
    let dateFont = UIFont(name: "Verdana", size: 11)!
    
    var countButton = UIButton()
    var likesButton = UIButton()
    let commentLabel = UILabel()
    
    func configureCountCell(count: Int, total: Int) {
        
        self.removeAllSubviews()
        
        countButton.tag = 250
        countButton.setTitle("Показать еще \(count) из \(total) комментариев", for: .normal)
        countButton.setTitleColor(countButton.titleLabel?.tintColor, for: .normal)
        countButton.contentMode = .center
        countButton.titleLabel?.font = UIFont(name: "Verdana", size: 13)!
        countButton.titleLabel?.adjustsFontSizeToFitWidth = true
        countButton.titleLabel?.minimumScaleFactor = 0.5
        countButton.frame = CGRect(x: 20, y: 0, width: bounds.width-40, height: bounds.height)
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
            
            topY = setInfoPanel(topY: topY)
        }
        
    }
    
    func setText(topY: CGFloat) -> CGFloat {
        
        var topY = topY
        
        commentLabel.tag = 250
        commentLabel.text = comment.text
        commentLabel.font = textFont
        commentLabel.numberOfLines = 0
        commentLabel.prepareTextForPublish2(delegate)
        
        let maxWidth = cellWidth - avatarHeight - 40
        let size = delegate.getTextSize(text: commentLabel.text!, font: textFont, maxWidth: maxWidth)
        
        commentLabel.frame = CGRect(x: avatarHeight + 20, y: topY, width: maxWidth, height: size.height)
        self.addSubview(commentLabel)
        
        let tap = UITapGestureRecognizer()
        commentLabel.isUserInteractionEnabled = true
        commentLabel.addGestureRecognizer(tap)
        tap.add {
            
        }
        
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
        
        let avatarImage = UIImageView()
        let nameLabel = UILabel()
        
        avatarImage.tag = 250
        nameLabel.tag = 250
        
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
    
    func setInfoPanel(topY: CGFloat) -> CGFloat {
        
        let dateLabel = UILabel()
        
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
        
        height += likesButtonHeight
        
        if height1 > height {
            return height1
        }
        
        return height
    }
}
