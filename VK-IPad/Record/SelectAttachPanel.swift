//
//  SelectAttachPanel.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 02.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Popover

class SelectAttachPanel: UIView {

    var actions: [Int:String] = [
        0: "Упомянуть себя в сообщении",
        1: "Упомянуть друга в сообщении",
        2: "Упомянуть сообщество в сообщении",
        3: "Вложить фотографию из профиля",
        4: "Вложить фотографию с устройства",
        5: "Сфотографировать с устройства",
        6: "Вложить видеозапись из профиля"
        ]
    
    var sizes: [String: CGSize] = [:]
    var maxWidth: CGFloat = 400
    
    var delegate: UIViewController!
    var button: UIButton!
    
    var attachPanel: AttachPanel!
    var popover: Popover!

    let textFont = UIFont(name: "Verdana", size: 18)!
    
    func show() {
        
        let popoverOptions: [PopoverOption] = [
            .type(.up),
            .cornerRadius(20),
            .color(UIColor.white),
            .blackOverlayColor(UIColor.gray.withAlphaComponent(0.75))
        ]
        
        
        self.configure()
        let point = CGPoint(x: button.frame.midX, y: delegate.view.frame.height - 12 - button.frame.height)
        
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
                    
                }

                if key == 5 {
                    
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
}
