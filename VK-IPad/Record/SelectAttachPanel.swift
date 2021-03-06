//
//  SelectAttachPanel.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 02.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Photos
import Popover

class SelectAttachPanel: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var load = LoadToServer()
    
    var titleGen: String {
        if delegate is NewRecordController {
            return "тексте записи"
        } else if delegate is DialogController {
             return "сообщении"
        } else {
            return "комментарии"
        }
    }
    
    var titleAbl: String {
        if delegate is NewRecordController {
            return "записи"
        } else if delegate is DialogController {
             return "сообщению"
        } else {
            return "комментарию"
        }
    }
    
    var actions: [Int:String] {
        if delegate is NewRecordController {
            return [
                0: "Упомянуть себя в \(titleGen)",
                1: "Упомянуть друга в \(titleGen)",
                2: "Упомянуть сообщество в \(titleGen)",
                3: "Прикрепить фотографию из профиля",
                4: "Прикрепить фотографию с устройства",
                5: "Сфотографировать с устройства",
                6: "Прикрепить видеозапись из профиля",
                7: "Прикрепить внешнюю ссылку"
                ]
        }
        
        if delegate is AddNewTopicController {
            return [
                3: "Прикрепить фотографию из профиля",
                4: "Прикрепить фотографию с устройства",
                5: "Сфотографировать с устройства",
                6: "Прикрепить видеозапись из профиля",
            ]
        }
        
        return [
            0: "Упомянуть себя в \(titleGen)",
            1: "Упомянуть друга в \(titleGen)",
            2: "Упомянуть сообщество в \(titleGen)",
            3: "Прикрепить фотографию из профиля",
            4: "Прикрепить фотографию с устройства",
            5: "Сфотографировать с устройства",
            6: "Прикрепить видеозапись из профиля"
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
        if delegate is NewRecordController || delegate is AddNewTopicController {
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
        
        for key in actions.keys.sorted() {
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
                        } else if let controller = self.delegate as? DialogController {
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
                    controller.title = "Упомянуть друга в \(self.titleGen)"
                    
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
                    controller.title = "Упомянуть сообщество в \(self.titleGen)"
                    
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
                    controller.title = "Прикрепить фото к \(self.titleAbl)"
                    
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
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.myOrientation = .all
                    
                    let status = PHPhotoLibrary.authorizationStatus()
                    switch status {
                    case .authorized:
                        self.delegate.present(self.pickerController, animated: true)
                    case .denied, .restricted:
                        if let title = self.actions[key] {
                            self.delegate.showErrorMessage(title: title, msg: "Доступ к галерее устройства запрещен.\nВы можете поменять это в разделе «Настройки»\nвашего устройства.")
                        }
                    case .notDetermined:
                        PHPhotoLibrary.requestAuthorization() { status in
                            if status == .authorized {
                                self.delegate.present(self.pickerController, animated: true)
                            }
                        }
                    }
                }

                if key == 5 {
                    self.load.delegate = self.delegate
                    self.pickerController.delegate = self
                    
                    
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
                        switch status {
                        case .authorized:
                            self.pickerController.sourceType = .camera
                            self.pickerController.cameraCaptureMode = .photo
                            self.pickerController.modalPresentationStyle = .currentContext
                            
                            self.delegate.present(self.pickerController, animated: true)
                        case .denied, .restricted:
                            if let title = self.actions[key] {
                                self.delegate.showErrorMessage(title: title, msg: "Доступ к камере устройства запрещен.\nВы можете поменять это в разделе «Настройки»\nвашего устройства.")
                            }
                        case .notDetermined:
                            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                                if granted {
                                    self.pickerController.sourceType = .camera
                                    self.pickerController.cameraCaptureMode = .photo
                                    self.pickerController.modalPresentationStyle = .currentContext
                                    
                                    self.delegate.present(self.pickerController, animated: true)
                                }
                            }
                        }
                    } else {
                        if let title = self.actions[key] {
                            self.delegate.showErrorMessage(title: title, msg: "Камера не активна либо отсутствует на устройстве.")
                        }
                    }
                }

                if key == 6 {
                    let controller = self.delegate.storyboard?.instantiateViewController(withIdentifier: "VideoListController") as! VideoListController
                    
                    controller.delegate = self.delegate
                    controller.ownerID = vkSingleton.shared.userID
                    controller.type = ""
                    controller.source = "add_video"
                    controller.title = "Прикрепить видео к \(self.titleAbl)"
                    
                    if let split = self.delegate.splitViewController {
                        let detail = split.viewControllers[split.viewControllers.endIndex - 1]
                        detail.childViewControllers[0].navigationController?.pushViewController(controller, animated: true)
                    }
                }
                
                if key == 7 {
                    self.getLink()
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
    
    func getLink() {
        
        if let controller = self.delegate as? NewRecordController {
            let alertController = UIAlertController(title: "Введите внешнюю ссылку", message: nil, preferredStyle: .alert)
            
            alertController.addTextField { (textField) -> Void in }
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Отмена", style: .cancel)
            alertController.addAction(cancelAction)
        
            let doneAction = UIAlertAction(title: "Готово", style: .default) { action -> Void in
                
                let textField = alertController.textFields!.first
                
                if let link = textField?.text, URL(string: link) != nil {
                    controller.attachPanel.link = link
                    controller.attachPanel.removeFromSuperview()
                    controller.attachPanel.reconfigure()
                    controller.tableView.reloadData()
                } else {
                    controller.showErrorMessage(title: "Внешняя ссылка", msg: "\nОшибка! Неверный формат введенной ссылки.\n")
                }
            }
            alertController.addAction(doneAction)
            
            
            
            if let popoverController = alertController.popoverPresentationController {
                let bounds = controller.view.bounds
                popoverController.sourceView = controller.view
                popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            controller.present(alertController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.myOrientation = .landscape
        
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
                        } else if let controller = self.delegate as? AddNewTopicController {
                            controller.tableView.reloadData()
                        } else if let controller = self.delegate as? DialogController {
                            controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
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
                        } else if let controller = self.delegate as? AddNewTopicController {
                            controller.tableView.reloadData()
                        } else if let controller = self.delegate as? DialogController {
                            controller.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                        }
                    }
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIImagePickerController {
    override open var shouldAutorotate: Bool {
        return true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
