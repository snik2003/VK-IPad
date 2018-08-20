//
//  Comment.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 20.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Comment {
    var id: Int = 0
    var fromID: Int = 0
    var date: Int = 0
    var text: String = ""
    var canLike = 0
    var userLikes = 0
    var countLikes = 0
    var replyUser = 0
    var replyComment = 0
    
    var attachments: [Attachment] = []
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.fromID = json["from_id"].intValue
        self.date = json["date"].intValue
        self.text = json["text"].stringValue
        self.canLike = json["likes"]["can_like"].intValue
        self.userLikes = json["likes"]["user_likes"].intValue
        self.countLikes = json["likes"]["count"].intValue
        self.replyUser = json["reply_to_user"].intValue
        self.replyComment = json["reply_to_comment"].intValue
        
        self.attachments = json["attachments"].compactMap({ Attachment(json: $0.1) })
    }
}

extension Comment {
    
    var isSticker: Bool {
        var res = false
        for attach in self.attachments {
            if attach.sticker.count > 0 {
                res = true
            }
        }
        return res
    }
    
    func reportMenu(delegate: UIViewController) {
        
        var title = ""
        
        if let controller = delegate as? RecordController {
            if controller.type == "post" {
                title = "Жалоба на комментарий к записи"
            } else if controller.type == "photo" {
                title = "Жалоба на комментарий к фотографии"
            }
        } else if delegate is VideoController {
            title = "Жалоба на комментарий к видео"
        }
        
        
        let alertController = UIAlertController(title: title, message: "Укажите тип жалобы", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let action1 = UIAlertAction(title: "Это спам", style: .default) { action in
            
            self.reportComment(delegate: delegate, reason: 0)
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Детская порнография", style: .default) { action in
            
            self.reportComment(delegate: delegate, reason: 1)
        }
        alertController.addAction(action2)
        
        let action3 = UIAlertAction(title: "Экстремизм", style: .default) { action in
            
            self.reportComment(delegate: delegate, reason: 2)
        }
        alertController.addAction(action3)
        
        let action4 = UIAlertAction(title: "Насилие", style: .default) { action in
            
            self.reportComment(delegate: delegate, reason: 3)
        }
        alertController.addAction(action4)
        
        let action5 = UIAlertAction(title: "Пропаганда наркотиков", style: .default) { action in
            
            self.reportComment(delegate: delegate, reason: 4)
        }
        alertController.addAction(action5)
        
        let action6 = UIAlertAction(title: "Материал для взрослых", style: .default) { action in
            
            self.reportComment(delegate: delegate, reason: 5)
        }
        alertController.addAction(action6)
        
        let action7 = UIAlertAction(title: "Оскорбление", style: .default) { action in
            
            self.reportComment(delegate: delegate, reason: 6)
        }
        alertController.addAction(action7)
        
        let action8 = UIAlertAction(title: "Призывы к суициду", style: .default) { action in
            
            self.reportComment(delegate: delegate, reason: 8)
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
    
    func reportComment(delegate: UIViewController, reason: Int) {
        
        var title = ""
        var ownerID = ""
        var url = ""
        
        if let controller = delegate as? RecordController {
            if controller.type == "post" {
                url = "wall.reportComment"
                title = "Жалоба на комментарий к записи"
            } else if controller.type == "photo" {
                url = "photos.reportComment"
                title = "Жалоба на комментарий к фото"
            }
            ownerID = "\(controller.uid)"
        } else if let controller = delegate as? VideoController {
            url = "video.reportComment"
            title = "Жалоба на комментарий к видео"
            ownerID = "\(controller.ownerID)"
        }
        
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": ownerID,
            "comment_id": "\(self.id)",
            "reason": "\(reason)",
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
                delegate.showSuccessMessage(title: title, msg: "Ваша жалоба на комментарий успешно отправлена в администрацию сайта.")
            } else {
                delegate.showErrorMessage(title: title, msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
}
