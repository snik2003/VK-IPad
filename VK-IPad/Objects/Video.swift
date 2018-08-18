//
//  Video.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 16.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Video {
    var id = 0
    var ownerID = 0
    var title = ""
    var description = ""
    var duration = 0
    var photo130 = ""
    var photo320 = ""
    var photo640 = ""
    var photo800 = ""
    var date = 0
    var addingDate = 0
    var views = 0
    var comments = 0
    var player = ""
    var platform = ""
    var canEdit = 0
    var canAdd = 0
    var isPrivate = 0
    var accessKey = ""
    var processing = 0
    var live = 0
    var upcoming = 0

    var userLikes = 0
    var countLikes = 0
    var canComment = 0
    var userReposted = 0
    var countReposts = 0
    
    var isSelected = false
    
    init(json: JSON) {
        self.id = json["id"].intValue
        self.ownerID = json["owner_id"].intValue
        self.title = json["title"].stringValue
        self.description = json["description"].stringValue
        self.duration = json["duration"].intValue
        self.photo130 = json["photo_130"].stringValue
        self.photo320 = json["photo_320"].stringValue
        self.photo640 = json["photo_640"].stringValue
        self.photo800 = json["photo_800"].stringValue
        self.date = json["date"].intValue
        self.addingDate = json["adding_date"].intValue
        self.views = json["views"].intValue
        self.comments = json["comments"].intValue
        self.player = json["player"].stringValue
        self.platform = json["platform"].stringValue
        self.canEdit = json["can_edit"].intValue
        self.canAdd = json["can_add"].intValue
        self.isPrivate = json["is_private"].intValue
        self.accessKey = json["access_key"].stringValue
        self.processing = json["processing"].intValue
        self.live = json["live"].intValue
        self.upcoming = json["upcoming"].intValue
        
        self.canComment = json["can_comment"].intValue
        self.userLikes = json["likes"]["user_likes"].intValue
        self.countLikes = json["likes"]["count"].intValue
        self.userReposted = json["reposts"]["user_reposted"].intValue
        self.countReposts = json["reposts"]["count"].intValue
    }
}

extension Video: Equatable {
    
    static func == (lhs: Video, rhs: Video) -> Bool {
        if lhs.id == rhs.id && lhs.ownerID == rhs.ownerID {
            return true
        }
        return false
    }
    
    func addToFaveVideos(delegate: UIViewController) {
        
        let url = "/method/video.add"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "target_id": vkSingleton.shared.userID,
            "owner_id": "\(ownerID)",
            "video_id": "\(id)",
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
                delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nВидеозапись «\(self.title)» успешно добавлена в раздел «Мои видеозаписи».\n")
            } else {
                if error.errorCode == 800 {
                    delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nЭта видеозапись уже ранее была добавлена в раздел «Мои видеозаписи».\n")
                } else if error.errorCode == 204 {
                    delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nОшибка. Нет доступа.\n")
                } else {
                    delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                }
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func deleteFromFaveVideos(delegate: UIViewController) {
        
        let url = "/method/video.delete"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "target_id": vkSingleton.shared.userID,
            "owner_id": "\(ownerID)",
            "video_id": "\(id)",
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
                delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nВидеозапись «\(self.title)» успешно удалена из раздела «Мои видеозаписи».\n")
            } else {
                delegate.showSuccessMessage(title: "Мои видеозаписи", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func deleteFromSite(delegate: UIViewController) {
        
        let url = "/method/video.delete"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "photo_id": "\(id)",
            "owner_id": "\(ownerID)",
            "target_id": "\(ownerID)",
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
                    delegate.navigationController?.popViewController(animated: true)
                }
                
                delegate.showSuccessMessage(title: "Удаление видеозаписи", msg: "Удаление видеозаписи успешно завершено. Для завершения обновите информацию на экране.")
            } else {
                delegate.showErrorMessage(title: "Удаление видеозаписи", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func reportMenu(delegate: UIViewController) {
        let alertController = UIAlertController(title: "Жалоба на видеозапись", message: "Введите комментарий и укажите тип жалобы", preferredStyle: .alert)
        
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
                self.reportVideo(delegate: delegate, reason: 0, comment: yourComment)
            }
        }
        alertController.addAction(action1)
        
        let action2 = UIAlertAction(title: "Детская порнография", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportVideo(delegate: delegate, reason: 1, comment: yourComment)
            }
        }
        alertController.addAction(action2)
        
        let action3 = UIAlertAction(title: "Экстремизм", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportVideo(delegate: delegate, reason: 2, comment: yourComment)
            }
        }
        alertController.addAction(action3)
        
        let action4 = UIAlertAction(title: "Насилие", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportVideo(delegate: delegate, reason: 3, comment: yourComment)
            }
        }
        alertController.addAction(action4)
        
        let action5 = UIAlertAction(title: "Пропаганда наркотиков", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportVideo(delegate: delegate, reason: 4, comment: yourComment)
            }
        }
        alertController.addAction(action5)
        
        let action6 = UIAlertAction(title: "Материал для взрослых", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportVideo(delegate: delegate, reason: 5, comment: yourComment)
            }
        }
        alertController.addAction(action6)
        
        let action7 = UIAlertAction(title: "Оскорбление", style: .default) { action in
            
            if let textView = alertController.textFields?.first, let yourComment = textView.text {
                self.reportVideo(delegate: delegate, reason: 6, comment: yourComment)
            }
        }
        alertController.addAction(action7)
        
        
        if let popoverController = alertController.popoverPresentationController {
            let bounds = delegate.view.bounds
            popoverController.sourceView = delegate.view
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        delegate.present(alertController, animated: true)
    }
    
    func reportVideo(delegate: UIViewController, reason: Int, comment: String) {
        
        let url = "/method/video.report"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "owner_id": "\(self.ownerID)",
            "video_id": "\(self.id)",
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
                delegate.showSuccessMessage(title: "Жалоба на видеозапись", msg: "Ваша жалоба на видеозапись успешно отправлена в администрацию сайта.")
            } else {
                delegate.showErrorMessage(title: "Жалоба на видеозапись", msg: "#\(error.errorCode): \(error.errorMsg)")
            }
        }
        OperationQueue().addOperation(request)
    }
}
