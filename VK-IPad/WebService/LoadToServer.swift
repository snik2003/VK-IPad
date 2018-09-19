//
//  LoadToServer.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 10.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoadToServer {
    
    weak var delegate: UIViewController!
    
    func wallPhoto(ownerID: String, image: UIImage, filename: String, completion: @escaping ([Photo]) -> Void) {
        
        ViewControllerUtils().showActivityIndicator(uiView: self.delegate.view)
        
        var url = "/method/photos.getWallUploadServer"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
        ]
        
        if let id = Int(ownerID), id < 0 {
            parameters["group_id"] = "\(abs(id))"
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                let uploadURL = json["response"]["upload_url"].stringValue
                
                self.myImageUploadRequest(url: uploadURL, image: image, filename: filename, squareCrop: "") { json2, errJson in
                    
                    if errJson.errorMsg == "" {
                        let photo = json2["photo"].stringValue
                        let server = json2["server"].intValue
                        let hash = json2["hash"].stringValue
                        
                        url = "/method/photos.saveWallPhoto"
                        parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "photo": photo,
                            "server": "\(server)",
                            "hash": hash,
                            "v": vkSingleton.shared.version
                        ]
                        
                        if let id = Int(ownerID), id < 0 {
                            parameters["group_id"] = "\(abs(id))"
                        } else {
                            parameters["user_id"] = ownerID
                        }
                        
                        let request = GetServerDataOperation(url: url, parameters: parameters)
                        
                        request.completionBlock = {
                            guard let data = request.data else { return }
                            
                            let json3 = try! JSON(data: data)
                            //print(json3)
                            
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json3["error"]["error_code"].intValue
                            error.errorMsg = json3["error"]["error_msg"].stringValue
                            
                            if error.errorCode == 0 {
                                let photos = json3["response"].compactMap { Photo(json: $0.1) }
                                completion(photos)
                            } else {
                                OperationQueue.main.addOperation {
                                    ViewControllerUtils().hideActivityIndicator()
                                }
                                self.delegate.showErrorMessage(title: "Загрузка фотографии", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                            }
                        }
                        OperationQueue().addOperation(request)
                    }
                }
            } else {
                OperationQueue.main.addOperation {
                    ViewControllerUtils().hideActivityIndicator()
                }
                self.delegate.showErrorMessage(title: "Загрузка фотографии", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
            }
        }
        OperationQueue().addOperation(request)
    }
    
    func wallDocument(ownerID: String, image: UIImage, filename: String, imageData: Data, completion: @escaping ([Document]) -> Void) {
        
        ViewControllerUtils().showActivityIndicator(uiView: self.delegate.view)
        
        var url = "/method/docs.getWallUploadServer"
        var parameters = [
            "access_token": vkSingleton.shared.accessToken,
            "v": vkSingleton.shared.version
        ]
        
        if let id = Int(ownerID), id < 0 {
            parameters["group_id"] = "\(abs(id))"
        }
        
        let request = GetServerDataOperation(url: url, parameters: parameters)
        
        request.completionBlock = {
            guard let data = request.data else { return }
            
            guard let json = try? JSON(data: data) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorCode = json["error"]["error_code"].intValue
            error.errorMsg = json["error"]["error_msg"].stringValue
            
            if error.errorCode == 0 {
                let uploadURL = json["response"]["upload_url"].stringValue
                
                self.myGifUploadRequest(url: uploadURL, imageData: imageData, filename: filename) { json2, errJson in
                    if errJson.errorMsg == "" {
                        let file = json2["file"].stringValue
                        
                        url = "/method/docs.save"
                        parameters = [
                            "access_token": vkSingleton.shared.accessToken,
                            "file": file,
                            "v": vkSingleton.shared.version
                        ]
                        
                        let request = GetServerDataOperation(url: url, parameters: parameters)
                        
                        request.completionBlock = {
                            guard let data = request.data else { return }
                            
                            let json3 = try! JSON(data: data)
                            //print(json3)
                            
                            let error = ErrorJson(json: JSON.null)
                            error.errorCode = json3["error"]["error_code"].intValue
                            error.errorMsg = json3["error"]["error_msg"].stringValue
                            
                            if error.errorCode == 0 {
                                let docs = json3["response"].compactMap { Document(json: $0.1) }
                                completion(docs)
                            } else {
                                OperationQueue.main.addOperation {
                                    ViewControllerUtils().hideActivityIndicator()
                                }
                                self.delegate.showErrorMessage(title: "Загрузка GIF-изображения", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
                            }
                        }
                        OperationQueue().addOperation(request)
                    }
                }
            } else {
                OperationQueue.main.addOperation {
                    ViewControllerUtils().hideActivityIndicator()
                }
                self.delegate.showErrorMessage(title: "Загрузка GIF-изображения", msg: "\nОшибка #\(error.errorCode): \(error.errorMsg)\n")
            }
        }
        OperationQueue().addOperation(request)
    }
}

extension LoadToServer {
    func myImageUploadRequest(url: String, image: UIImage, filename: String, squareCrop: String, completion: @escaping (JSON, ErrorJson) -> Void) {
        
        let myUrl = NSURL(string: url)
        
        let request = NSMutableURLRequest(url: myUrl! as URL)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let imageData = UIImageJPEGRepresentation(image, 1)
        
        if imageData == nil { return }
        
        request.httpBody = createBodyWithParameters(filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary, filepath: filename, squareCrop: squareCrop) as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard let json = try? JSON(data: data!) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorMsg = json["error"].stringValue
            
            if error.errorMsg != "" {
                OperationQueue.main.addOperation {
                    ViewControllerUtils().hideActivityIndicator()
                }
                self.delegate.showErrorMessage(title: "Загрузка фотографии", msg: "\n\(error.errorMsg)\n")
            }
            completion(json,error)
        }
        
        task.resume()
    }
    
    func myGifUploadRequest(url: String, imageData: Data, filename: String, completion: @escaping (JSON, ErrorJson) -> Void) {
        
        let myUrl = NSURL(string: url)
        
        let request = NSMutableURLRequest(url: myUrl! as URL)
        request.httpMethod = "POST"
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = createBodyWithParameters(filePathKey: "file", imageDataKey: imageData as NSData, boundary: boundary, filepath: filename, squareCrop: "") as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            guard let json = try? JSON(data: data!) else { print("json error"); return }
            
            let error = ErrorJson(json: JSON.null)
            error.errorMsg = json["error"].stringValue
        
            
            if error.errorMsg != "" {
                OperationQueue.main.addOperation {
                    ViewControllerUtils().hideActivityIndicator()
                }
                self.delegate.showErrorMessage(title: "Загрузка GIF-изображения", msg: "\n\(error.errorMsg)\n")
            }
            
            completion(json,error)
        }
        
        task.resume()
    }
    
    func createBodyWithParameters(filePathKey: String?, imageDataKey: NSData, boundary: String, filepath: String, squareCrop: String) -> NSData {
        
        let body = NSMutableData();
        
        if squareCrop != "" {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"_square_crop\"\r\n\r\n")
            body.appendString(string: "\(squareCrop)\r\n")
        }
        
        var filename = "photo.jpg"
        var mimetype = "image/jpg"
        
        if filepath.hasSuffix("gif") {
            filename = "photo.gif"
            mimetype = "image/gif"
        }
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}

extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
