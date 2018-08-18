//
//  Record.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 15.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Record {
    var id = 0
    var ownerID = 0
    var fromID = 0
    var createdBy = 0
    var date = 0
    var text = ""
    var replyOwnerID = 0
    var replyPostID = 0
    var friendsOnly = 0
    var commentsCount = 0
    var canComment = 0
    var groupCanComment = 0
    var likesCount = 0
    var userLikes = 0
    var userCanLike = 0
    var userCanRepost = 0
    var repostCount = 0
    var userReposted = 0
    var viewsCount = 0
    var postType = ""
    var sourcePlatform = ""
    var signerID = 0
    var canPin = 0
    var canDelete = 0
    var canEdit = 0
    var isPinned = 0
    
    var attachments: [Attachment] = []
    var copy: [Record] = []
    
    var attachCount = 0
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.fromID = json["from_id"].intValue
        self.createdBy = json["created_by"].intValue
        self.date = json["date"].intValue
        self.replyOwnerID = json["reply_owner_id"].intValue
        self.replyPostID = json["reply_post_id"].intValue
        self.friendsOnly = json["friends_only"].intValue
        self.commentsCount = json["comments"]["count"].intValue
        self.canComment = json["comments"]["can_post"].intValue
        self.groupCanComment = json["comments"]["groups_can_post"].intValue
        self.likesCount = json["likes"]["count"].intValue
        self.userLikes = json["likes"]["user_likes"].intValue
        self.userCanLike = json["likes"]["can_like"].intValue
        self.userCanRepost = json["likes"]["can_publish"].intValue
        self.repostCount = json["reposts"]["count"].intValue
        self.userReposted = json["reposts"]["user_reposted"].intValue
        self.viewsCount = json["views"]["count"].intValue
        self.sourcePlatform = json["post_source"]["platform"].stringValue
        self.signerID = json["signer_id"].intValue
        self.canPin = json["can_pin"].intValue
        self.canDelete = json["can_delete"].intValue
        self.canEdit = json["can_edit"].intValue
        self.isPinned = json["is_pinned"].intValue
        
        self.text = json["text"].stringValue
        self.postType = json["post_type"].stringValue
        
        self.attachments = json["attachments"].compactMap({ Attachment(json: $0.1) })
        self.copy = json["copy_history"].compactMap({ Record(json: $0.1) })
        
        if self.fromID == 0 {
            self.fromID = json["source_id"].intValue
        }
        if self.ownerID == 0 {
            self.ownerID = json["source_id"].intValue
        }
        
        if self.id == 0 {
            self.id = json["post_id"].intValue
        }
        
        for attach in self.attachments {
            if attach.photo.count > 0 {
                self.attachCount += 1
            }
        }
    }
}

extension Record {
    
    var title: String {
        var title = ""
        
        var str = self.text.prepareTextForPublic().replacingOccurrences(of: "\n", with: " ")
        if self.text == "" && self.copy.count > 0 {
            str = "\(self.copy[0].text.prepareTextForPublic().replacingOccurrences(of: "\n", with: " "))"
        }
        var str1 = str.components(separatedBy: [".", "!", "?", "\n"])
        
        if str1[0] != "" {
            title = "«\(str1[0].prefix(50))»"
        }
        
        return title
    }
    
    func reportMenu(delegate: UIViewController) {
        let alertController = UIAlertController(title: "Жалоба на запись", message: "Введите комментарий и укажите тип жалобы", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        alertController.addTextField(configurationHandler: { textField in
            textField.placeholder = "Комментарий к жалобе"
            textField.font = UIFont(name: "Verdana", size: 14)
            textField.layer.borderColor = vkSingleton.shared.mainColor.cgColor
            textField.layer.cornerRadius = 4
            textField.resignFirstResponder()
        })
        
        let action1 = UIAlertAction(title: "Это спам", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPost(delegate: delegate, reason: 0, comment: yourComment)
            }
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Детская порнография", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPost(delegate: delegate, reason: 1, comment: yourComment)
            }
        }
        alertController.addAction(action2)
        
        let action3 = UIAlertAction(title: "Экстремизм", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPost(delegate: delegate, reason: 2, comment: yourComment)
            }
        }
        alertController.addAction(action3)
        
        let action4 = UIAlertAction(title: "Насилие", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPost(delegate: delegate, reason: 3, comment: yourComment)
            }
        }
        alertController.addAction(action4)
        
        let action5 = UIAlertAction(title: "Пропаганда наркотиков", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPost(delegate: delegate, reason: 4, comment: yourComment)
            }
        }
        alertController.addAction(action5)
        
        let action6 = UIAlertAction(title: "Материал для взрослых", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPost(delegate: delegate, reason: 5, comment: yourComment)
            }
        }
        alertController.addAction(action6)
        
        let action7 = UIAlertAction(title: "Оскорбление", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPost(delegate: delegate, reason: 6, comment: yourComment)
            }
        }
        alertController.addAction(action7)
        
        let action8 = UIAlertAction(title: "Призывы к суициду", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportPost(delegate: delegate, reason: 8, comment: yourComment)
            }
        }
        alertController.addAction(action8)
        
        
        if let popoverController = alertController.popoverPresentationController {
            let bounds = delegate.view.bounds
            popoverController.sourceView = delegate.view
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        delegate.present(alertController, animated: true)
    }
    
    func reportPost(delegate: UIViewController, reason: Int, comment: String) {
        
        let url = "/method/wall.reportPost"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": "\(self.ownerID)",
            "post_id": "\(self.id)",
            "reason": "\(reason)",
            "comment": comment,
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
                delegate.showSuccessMessage(title: "Жалоба на запись", msg: "Ваша жалоба на запись успешно отправлена в администрацию сайта.")
            } else {
                delegate.showErrorMessage(title: "Жалоба на запись", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
}
