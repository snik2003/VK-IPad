//
//  RecordCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 15.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {
    
    var delegate: UIViewController!
    var record: Record!
    var users: [UserProfile]!
    var groups: [GroupProfile]!
    
    var cellWidth: CGFloat = 0
    var leftX: CGFloat = 20
    
    let avatarHeight: CGFloat = 50
    let avatarHeight2: CGFloat = 40
    
    var answerLabels: [UILabel] = []
    var rateLabels: [UILabel] = []
    var totalLabel = UILabel()
    
    let friendsOnlyLabel = UILabel()
    
    let textFont = UIFont(name: "TrebuchetMS", size: 13)!
    let nameFont = UIFont(name: "TrebuchetMS-Bold", size: 14)!
    let qLabelFont = UIFont(name: "TrebuchetMS-Bold", size: 13)!
    let aLabelFont = UIFont(name: "TrebuchetMS", size: 12)!
    
    var poll: Poll!
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        answerLabels.removeAll(keepingCapacity: false)
        rateLabels.removeAll(keepingCapacity: false)
        
        if let record = record {
            
            //collectionView.delegate = self
            
            var topY: CGFloat = 0
            leftX = 20
            setOnlyFriends()
            
            setHeader(topY: topY, size: avatarHeight, record: record)
            
            topY += 5 + avatarHeight + 5
            topY = setText(text: record.text, topY: topY)
            
            topY -= 5
            for attach in record.attachments {
                if attach.type != "audio" && attach.type != "link" && attach.type != "poll" {
                    topY += 5
                    topY = setAttachment(attach, topY: topY)
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
                    setHeader(topY: topY, size: avatarHeight2, record: record.copy[index])
                    
                    topY += 5 + avatarHeight2 + 5
                    topY = setText(text: record.copy[index].text, topY: topY)
                    
                    topY -= 5
                    for attach in record.copy[index].attachments {
                        if attach.type != "audio" && attach.type != "link" && attach.type != "poll" {
                            topY += 5
                            topY = setAttachment(attach, topY: topY)
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
                    
                    let x2 = topY
                    drawRepostLine(x1, x2)
                }
            }
        }
    }
        
    
    func setOnlyFriends() {
        
        if let record = self.record {
            if record.friendsOnly == 1 {
                let friendsOnlyLabel = UILabel()
                
                friendsOnlyLabel.tag = 250
                friendsOnlyLabel.text = "Запись только друзей!"
                friendsOnlyLabel.textAlignment = .right
                friendsOnlyLabel.font = UIFont(name: "TrebuchetMS", size: 12)!
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
                avatarImage.layer.borderColor = UIColor.lightGray.cgColor
                avatarImage.layer.borderWidth = 0.6
                avatarImage.layer.cornerRadius = size/2
                avatarImage.clipsToBounds = true
            }
        }
        OperationQueue().addOperation(getCacheImage)
        
        nameLabel.text = name
        nameLabel.font = nameFont
        
        dateLabel.text = record.date.toStringLastTime()
        dateLabel.font = UIFont(name: "TrebuchetMS", size: 12)!
        dateLabel.isEnabled = false
        
        avatarImage.frame = CGRect(x: leftX - 10, y: topY + 5, width: size, height: size)
        nameLabel.frame = CGRect(x: avatarImage.frame.maxX + 10, y: avatarImage.frame.midY - 20, width: cellWidth - avatarImage.frame.maxX - 20, height: 20)
        dateLabel.frame = CGRect(x: avatarImage.frame.maxX + 10, y: avatarImage.frame.midY, width: cellWidth - avatarImage.frame.maxX - 20, height: 16)
        
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
    
    func setAttachment(_ attach: Attachment, topY: CGFloat) -> CGFloat {
    
        var topY = topY
        
        let maxSize = cellWidth - leftX - 20
        
        if attach.type == "photo" && attach.photo.count > 0 {
            if attach.photo[0].width > 0 && attach.photo[0].height > 0 {
                var photoWidth = CGFloat(attach.photo[0].width)
                var photoHeight = CGFloat(attach.photo[0].height)
                
                if photoWidth > photoHeight {
                    photoWidth = maxSize/2
                    photoHeight = photoWidth * CGFloat(attach.photo[0].height) / CGFloat(attach.photo[0].width)
                } else {
                    photoHeight = maxSize/2
                    photoWidth = photoHeight * CGFloat(attach.photo[0].width) / CGFloat(attach.photo[0].height)
                }
                
                let photo = UIImageView()
                photo.tag = 250
                
                var url = attach.photo[0].photo1280
                if url == "" {
                    url = attach.photo[0].photo807
                    if url == "" {
                        url = attach.photo[0].photo604
                    }
                    if url == "" {
                        url = attach.photo[0].photo130
                    }
                }
                let getCacheImage = GetCacheImage(url: url, lifeTime: .userPhotoImage)
                getCacheImage.completionBlock = {
                    OperationQueue.main.addOperation {
                        photo.image = getCacheImage.outputImage
                        photo.clipsToBounds = true
                        photo.contentMode = .scaleToFill
                    }
                }
                OperationQueue().addOperation(getCacheImage)
                
                
                photo.frame = CGRect(x: leftX, y: topY, width: photoWidth, height: photoHeight)
                self.addSubview(photo)
                
                topY += photoHeight
            }
        }
        
        if attach.type == "video" && attach.video.count > 0 {
            let videoWidth: CGFloat = 320
            let videoHeight: CGFloat = 240
            
            let video = UIImageView()
            video.tag = 250
            
            let getCacheImage = GetCacheImage(url: attach.video[0].photo320, lifeTime: .userPhotoImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    video.image = getCacheImage.outputImage
                    video.layer.borderWidth = 0.6
                    video.layer.borderColor = UIColor.gray.cgColor
                    video.layer.cornerRadius = 12
                    video.clipsToBounds = true
                    video.contentMode = .scaleToFill
                }
            }
            OperationQueue().addOperation(getCacheImage)
            
            let videoImage = UIImageView()
            videoImage.image = UIImage(named: "video")
            videoImage.frame = CGRect(x: videoWidth / 2 - 30, y: (videoHeight - 4) / 2 - 30, width: 60, height: 60)
            video.addSubview(videoImage)
            
            
            let durationLabel = UILabel()
            durationLabel.text = attach.video[0].duration.getVideoDurationToString()
            durationLabel.font = UIFont(name: "Verdana-Bold", size: 12.0)!
            durationLabel.textAlignment = .center
            durationLabel.textColor = UIColor.black
            durationLabel.backgroundColor = UIColor.lightText.withAlphaComponent(0.5)
            durationLabel.layer.cornerRadius = 10
            durationLabel.clipsToBounds = true
            if let length = durationLabel.text?.length, length > 5 {
                durationLabel.frame = CGRect(x: videoWidth - 10 - 90, y: videoHeight - 4 - 10 - 20, width: 90, height: 20)
            } else {
                durationLabel.frame = CGRect(x: videoWidth - 10 - 60, y: videoHeight - 4 - 10 - 20, width: 60, height: 20)
            }
            video.addSubview(durationLabel)
            
            
            video.frame = CGRect(x: leftX, y: topY, width: videoWidth, height: videoHeight)
            self.addSubview(video)
            
            topY += videoHeight
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
        artistLabel.font = UIFont(name: "TrebuchetMS", size: 13)!
        
        let titleLabel = UILabel()
        titleLabel.tag = 250
        titleLabel.frame = CGRect(x: leftX + 50, y: musicImage.frame.midY, width: maxSize - 50, height: 16)
        titleLabel.text = attach.audio[0].title
        titleLabel.textColor = titleLabel.tintColor
        titleLabel.font = UIFont(name: "TrebuchetMS", size: 13)!
        
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
        titleLabel.font = UIFont(name: "TrebuchetMS", size: 13)!
        
        let linkLabel = UILabel()
        linkLabel.tag = 250
        linkLabel.frame = CGRect(x: leftX + 50, y: linkImage.frame.midY, width: maxSize - 50, height: 16)
        if let url = URL(string: attach.link[0].url), let host = url.host {
            linkLabel.text = host
        } else {
            linkLabel.text = attach.link[0].url
        }
        linkLabel.textColor = linkLabel.tintColor
        linkLabel.font = UIFont(name: "TrebuchetMS", size: 13)!
        
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
        let width = (cellWidth - leftX - 20) * 2 / 3
        
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
            rLabel.font = UIFont(name: "TrebuchetMS-Bold", size: 10)!
            rLabel.frame = CGRect(x: 5, y: viewY+5, width: width - 10, height: 15)
            view.addSubview(rLabel)
            rateLabels.append(rLabel)
            
            
            viewY += 25
            answerLabels.append(aLabel)
        }
        
        totalLabel.font = UIFont(name: "TrebuchetMS-Bold", size: 12)!
        totalLabel.textAlignment = .right
        totalLabel.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        totalLabel.isEnabled = true
        totalLabel.numberOfLines = 1
        
        totalLabel.frame = CGRect(x: 20, y: viewY, width: width - 40, height: 20)
        view.addSubview(totalLabel)
        viewY += 20
        
        let sdvig = (cellWidth - leftX - 20 - width) / 2
        view.frame = CGRect(x: leftX + sdvig, y: topY, width: width, height: viewY)
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
        view.backgroundColor = vkSingleton.shared.mainColor
        view.frame = CGRect(x: leftX - 20, y: x1, width: 3, height: x2 - x1)
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.2
        view.layer.cornerRadius = 0.5
        view.clipsToBounds = true
        
        self.addSubview(view)
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
        
        height -= 5
        for attach in record.attachments {
            height += 5
            if attach.type == "photo" && attach.photo.count > 0 {
                if attach.photo[0].width > 0 && attach.photo[0].height > 0 {
                    let photoHeight = CGFloat(attach.photo[0].height)
                    let maxSize = cellWidth - leftX - 20
                    
                    if CGFloat(attach.photo[0].width) > photoHeight {
                        height += maxSize / 2 * CGFloat(attach.photo[0].height) / CGFloat(attach.photo[0].width)
                    } else {
                        height += maxSize / 2
                    }
                }
            }
            
            if attach.type == "video" && attach.video.count > 0 {
                height += 240
            }
            
            if attach.type == "audio" && attach.audio.count > 0 {
                height += 40
            }
            
            if attach.type == "link" && attach.link.count > 0 {
                height += 40
            }
            
            if attach.type == "poll" && attach.poll.count > 0 {
                
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
                
                height -= 5
                for attach in record.copy[index].attachments {
                    height += 5
                    
                    if attach.type == "photo" && attach.photo.count > 0 {
                        if attach.photo[0].width > 0 && attach.photo[0].height > 0 {
                            let photoHeight = CGFloat(attach.photo[0].height)
                            let maxSize = cellWidth - leftX - 20
                            
                            if CGFloat(attach.photo[0].width) > photoHeight {
                                height += maxSize / 2 * CGFloat(attach.photo[0].height) / CGFloat(attach.photo[0].width)
                            } else {
                                height += maxSize / 2
                            }
                        }
                    }
                    
                    if attach.type == "video" && attach.video.count > 0 {
                        height += 240
                    }
                    
                    if attach.type == "audio" && attach.audio.count > 0 {
                        height += 40
                    }
                    
                    if attach.type == "link" && attach.link.count > 0 {
                        height += 40
                    }
                    
                    if attach.type == "poll" && attach.poll.count > 0 {
                        
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
            }
        }
        
        return height + 5
    }
}
