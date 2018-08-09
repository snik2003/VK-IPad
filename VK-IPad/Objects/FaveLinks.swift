//
//  FaveLinks.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 23.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation
import SwiftyJSON

class FaveLinks {
    var id: String = ""
    var title: String = ""
    var description: String = ""
    var photoURL: String = ""
    var url: String = ""
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.title = json["title"].stringValue
        self.description = json["description"].stringValue
        self.photoURL = json["photo_200"].stringValue
        self.url = json["url"].stringValue
    }
}

extension FaveLinks: Equatable {
    static func == (lhs: FaveLinks, rhs: FaveLinks) -> Bool {
        if lhs.id == rhs.id {
            return true
        }
        return false
    }
    
    func removeFromFave(delegate: UIViewController) {
        
        let url = "/method/fave.removeLink"
        let parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "link_id": self.id,
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
                    if let controller = delegate as? FavePostsController {
                        controller.links.remove(object: self)
                        controller.tableView.reloadData()
                    }
                }
            } else {
                delegate.showErrorMessage(title: "Избранные ссылки", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
            }
        }
        
        OperationQueue().addOperation(request)
    }
}

