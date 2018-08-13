//
//  SelectAttachPanel.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 02.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Popover

class SelectAttachPanel: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var load = LoadToServer()
    
    var titleGen: String {
        if delegate is NewRecordController {
            return "тексте записи"
        } /*else if delegate if DialogController {
             return "сообщении"
         } */else {
            return "комментарии"
        }
    }
    
    var actions: [Int:String] {
        return [
            0: "Упомянуть себя в \(titleGen)",
            1: "Упомянуть друга в \(titleGen)",
            2: "Упомянуть сообщество в \(titleGen)",
            3: "Вложить фотографию из профиля",
            4: "Вложить фотографию с устройства",
            5: "Сфотографировать с устройства",
            6: "Вложить видеозапись из профиля"
            ]
    }
    
    var sizes: [String: CGSize] = [:]
    var maxWidth: CGFloat = 400
    
    var delegate: UIViewController!
    var button: UIButton!
    
    var attachPanel: AttachPanel!
    var popover: Popover!

    var ownerID = ""
    
    let pickerController = UIImagePickerController()
    
    let textFont = UIFont(name: "Verdana", size: 18)!
    
    func show() {
        
        let popoverOptions: [PopoverOption] = [
            .type(.up),
            .cornerRadius(6),
            .color(UIColor.white),
            .blackOverlayColor(UIColor.gray.withAlphaComponent(0.75))
        ]
        
        
        self.configure()
        
        var point: CGPoint
        if delegate is NewRecordController {
            point = CGPoint(x: 100, y: delegate.view.frame.height - 46)
        } else {
            point = CGPoint(x: button.frame.midX, y: delegate.view.frame.height - 12 - button.frame.height)
        }
        
        popover = Popover(options: popoverOptions)
        popover.show(self, point: point, inView: self.delegate.view)
    }
    
    func configure() {
        var topY: CGFloat = 0
        var count = 0
        
        for key in 0...actions.keys.count - 1 {
            count += 1
            
            let label = UILabel()
            label.text = actions[key]
            label.textColor = label.tintColor
            label.font = textFont
            label.numberOfLines = 1
            label.textAlignment = .center
            label.minimumScaleFactor = 0.5
            label.adjustsFontSizeToFitWidth = true
            label.frame = CGRect(x: 20, y: topY, width: maxWidth - 40, height: 50)
            self.addSubview(label)
            
            let tap = UITapGestureRecognizer()
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tap)
            tap.add {
                if key == 0 {
                    if let user = vkSingleton.shared.myProfile {
                        let mention = "[id\(user.uid)|\(user.firstName) \(user.lastName)]"
                        
                        if let controller = self.delegate as? RecordController {
                            controller.commentView.textView.insertText(mention)
                        } else if let controller = self.delegate as? VideoController {
                            controller.commentView.textView.insertText(mention)
                        } else if let controller = self.delegate as? TopicController {
                            controller.commentView.textView.insertText(mention)
                        } else if let controller = self.delegate as? NewRecordController {
                            controller.textView.insertText(mention)
                        }
                    }
                }
                
                if key == 1 {
                    let controller = self.delegate.storyboard?.instantiateViewController(withIdentifier: "UsersController") as! UsersController
                    
                    controller.userID = vkSingleton.shared.userID
                    controller.type = "friends"
                    controller.source = "add_mention"
                    controller.title = "Упомянуть друга в сообщении/комментарии"
                    
                    controller.navigationItem.hidesBackButton = true
                    let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: controller, action: #selector(controller.tapCancelButton(sender:)))
                    controller.navigationItem.leftBarButtonItem = cancelButton
                    controller.delegate = self.delegate
                    
                    if let split = self.delegate.splitViewController {
                        let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                        detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
                    }
                }
                
                if key == 2 {
                    let controller = self.delegate.storyboard?.instantiateViewController(withIdentifier: "GroupsListController") as! GroupsListController
                    
                    controller.userID = vkSingleton.shared.userID
                    controller.type = ""
                    controller.source = "add_mention"
                    controller.title = "Упомянуть сообщество в сообщении/комментарии"
                    
                    controller.navigationItem.hidesBackButton = true
                    let cancelButton = UIBarButtonItem(title: "Отмена", style: .plain, target: controller, action: #selector(controller.tapCancelButton(sender:)))
                    controller.navigationItem.leftBarButtonItem = cancelButton
                    controller.delegate = self.delegate
                    
                    if let split = self.delegate.splitViewController {
                        let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                        detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
                    }
                }

                if key == 3 {
                    let controller = self.delegate.storyboard?.instantiateViewController(withIdentifier: "PhotosListController") as! PhotosListController
                    
                    controller.ownerID = vkSingleton.shared.userID
                    controller.title = "Вложить фотографии в сообщение/комментарий"
                    
                    controller.selectIndex = 0
                    
                    controller.delegate = self.delegate
                    controller.source = "add_photo"
                    
                    if let split = self.delegate.splitViewController {
                        let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                        detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
                    }
                }

                if key == 4 {
                    self.load.delegate = self.delegate
                    self.pickerController.delegate = self
                    
                    self.pickerController.sourceType = .photoLibrary
                    self.pickerController.mediaTypes =  UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                    
                    self.delegate.present(self.pickerController, animated: true)
                }

                if key == 5 {
                    self.load.delegate = self.delegate
                    self.pickerController.delegate = self
                    
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        self.pickerController.sourceType = .camera
                        self.pickerController.cameraCaptureMode = .photo
                        self.pickerController.modalPresentationStyle = .currentContext
                        
                        self.delegate.present(self.pickerController, animated: true)
                    } else {
                        
                        if let title = self.actions[key] {
                            self.delegate.showErrorMessage(title: title, msg: "Ошибка! Камера на устройстве не активна.")
                        }
                    }
                }

                if key == 6 {
                    let controller = self.delegate.storyboard?.instantiateViewController(withIdentifier: "VideoListController") as! VideoListController
                    
                    controller.delegate = self.delegate
                    controller.ownerID = vkSingleton.shared.userID
                    controller.type = ""
                    controller.source = "add_video"
                    controller.title = "Вложить видеозапись в сообщение/комментарий"
                    
                    if let split = self.delegate.splitViewController {
                        let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                        detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
                    }
                }
                
                self.popover.dismiss()
            }
            
            topY += 50
            if count < actions.count {
                drawSeparator(on: topY)
            }
        }
        
        self.frame = CGRect(x: 0, y: 0, width: maxWidth, height: topY)
    }
    
    func drawSeparator(on topY: CGFloat) {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        view.frame = CGRect(x: 10, y: topY, width: maxWidth - 20, height: 1)
        self.addSubview(view)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            ownerID = vkSingleton.shared.userID
            if vkSingleton.shared.commentFromGroup > 0 {
                ownerID = "-\(vkSingleton.shared.commentFromGroup)"
            }
            
            var type = "JPG"
            var path = NSURL(string: "photo.jpg")
            var imageData: Data!
            var filename = ""
            
            if pickerController.sourceType == .photoLibrary {
                if #available(iOS 11.0, *) {
                    path = info[UIImagePickerControllerImageURL] as? NSURL
                }
                
                if let str = path?.absoluteString, str.containsIgnoringCase(find: ".gif") {
                    type = "GIF"
                    imageData = try! Data(contentsOf: path! as URL)
                }
            }
            
            if let str = path?.absoluteString {
                filename = str
            }
            
            if type == "JPG" {
                load.wallPhoto(ownerID: ownerID, image: image, filename: filename) { photos in
                    OperationQueue.main.addOperation {
                        for photo in photos {
                            self.attachPanel.attachArray.append(photo)
                        }
                        self.attachPanel.removeFromSuperview()
                        self.attachPanel.reconfigure()
                        ViewControllerUtils().hideActivityIndicator()
                        if let controller = self.delegate as? NewRecordController {
                            controller.tableView.reloadData()
                        }
                    }
                }
            } else if type == "GIF" {
                load.wallDocument(ownerID: ownerID, image: image, filename: filename, imageData: imageData) { docs in
                    OperationQueue.main.addOperation {
                        for doc in docs {
                            self.attachPanel.attachArray.append(doc)
                        }
                        self.attachPanel.removeFromSuperview()
                        self.attachPanel.reconfigure()
                        ViewControllerUtils().hideActivityIndicator()
                        if let controller = self.delegate as? NewRecordController {
                            controller.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIImagePickerController {
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
