//
//  SelectMessagesPanel.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 30.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Popover

class SelectMessagesPanel: UIView {

    weak var delegate: DialogController!
    weak var dialog: Dialog!
    var indexPath: IndexPath!
    
    var popover: Popover!
    let popoverOptions: [PopoverOption] = [
        .type(.up),
        .arrowSize(CGSize(width: 0, height: 0)),
        .showBlackOverlay(false),
        .dismissOnBlackOverlayTap(false),
        .color(vkSingleton.shared.mainColor)]
    
    var editButton = UIButton()
    var copyButton = UIButton()
    var resendButton = UIButton()
    var deleteButton = UIButton()
    var importantButton = UIButton()
    
    func reconfigure() {
        
        if delegate.mode == .select {
            
            editButton.removeFromSuperview()
            copyButton.removeFromSuperview()
            
            let width: CGFloat = delegate.width - 40
            let height: CGFloat = 50
            self.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            let cancelButton = UIButton()
            cancelButton.setTitle("Отмена", for: .normal)
            cancelButton.setTitleColor(UIColor.white, for: .normal)
            cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
            cancelButton.titleLabel?.minimumScaleFactor = 0.5
            cancelButton.add(for: .touchUpInside) {
                self.delegate.mode = .dialog
                self.delegate.clearSelectedMessages()
                
                self.delegate.attachPanel.attachArray.removeAll(keepingCapacity: false)
                self.delegate.commentView.textView.text = ""
                vkSingleton.shared.forwardMessages.removeAll(keepingCapacity: false)
                
                self.reconfigure()
                self.delegate.attachPanel.reconfigure()
                
                self.delegate.tableView.reloadData()
                self.delegate.tableView.scrollToRow(at: self.indexPath, at: .bottom, animated: false)
            }
            cancelButton.frame = CGRect(x: 0, y: 10, width: 100, height: 30)
            self.addSubview(cancelButton)
            
            
            deleteButton.setTitle("Удалить", for: .normal)
            deleteButton.isEnabled = false
            deleteButton.setTitleColor(UIColor.white, for: .normal)
            deleteButton.setTitleColor(UIColor.lightGray, for: .disabled)
            deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            deleteButton.titleLabel?.adjustsFontSizeToFitWidth = true
            deleteButton.titleLabel?.minimumScaleFactor = 0.5
            deleteButton.add(for: .touchUpInside) {
                self.deleteButton.buttonTouched()
                self.deleteSelectedMessages()
            }
            let x1: CGFloat = 120
            deleteButton.frame = CGRect(x: x1, y: 10, width: (width - 120) * 0.25, height: 30)
            self.addSubview(deleteButton)
            
            resendButton.setTitle("Переслать", for: .normal)
            resendButton.isEnabled = false
            resendButton.setTitleColor(UIColor.white, for: .normal)
            resendButton.setTitleColor(UIColor.lightGray, for: .disabled)
            resendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            resendButton.titleLabel?.adjustsFontSizeToFitWidth = true
            resendButton.titleLabel?.minimumScaleFactor = 0.5
            resendButton.add(for: .touchUpInside) {
                self.resendButton.buttonTouched()
                self.resendSelectedMessages()
            }
            let x2: CGFloat = 120 + (width - 120) * 0.25
            resendButton.frame = CGRect(x: x2, y: 10, width: (width - 120) * 0.25, height: 30)
            self.addSubview(resendButton)
            
            
            importantButton.setTitle("Пометить как «Важное»", for: .normal)
            importantButton.isEnabled = false
            importantButton.setTitleColor(UIColor.white, for: .normal)
            importantButton.setTitleColor(UIColor.lightGray, for: .disabled)
            importantButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            importantButton.titleLabel?.adjustsFontSizeToFitWidth = true
            importantButton.titleLabel?.minimumScaleFactor = 0.5
            importantButton.add(for: .touchUpInside) {
                self.importantButton.buttonTouched()
                self.importantSelectedMessages()
            }
            let x3: CGFloat = 120 + (width - 120) * 0.5
            importantButton.frame = CGRect(x: x3, y: 10, width: (width - 120) * 0.5, height: 30)
            self.addSubview(importantButton)
            
            show()
            
            delegate.tableView.reloadData()
            delegate.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        
        if delegate.mode == .edit {
            
            importantButton.removeFromSuperview()
            
            let width: CGFloat = delegate.width - 40
            let height: CGFloat = 50
            self.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            let cancelButton = UIButton()
            cancelButton.setTitle("Отмена", for: .normal)
            cancelButton.setTitleColor(UIColor.white, for: .normal)
            cancelButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cancelButton.titleLabel?.adjustsFontSizeToFitWidth = true
            cancelButton.titleLabel?.minimumScaleFactor = 0.5
            cancelButton.add(for: .touchUpInside) {
                self.delegate.mode = .dialog
                self.delegate.clearSelectedMessages()
                
                self.delegate.commentView.textView.text = ""
                self.delegate.attachPanel.attachArray.removeAll(keepingCapacity: false)
                self.delegate.attachPanel.forwards = ""
                vkSingleton.shared.forwardMessages.removeAll(keepingCapacity: false)
                
                self.reconfigure()
                self.delegate.attachPanel.reconfigure()
                
                self.delegate.tableView.reloadData()
                self.delegate.tableView.scrollToRow(at: self.indexPath, at: .bottom, animated: false)
            }
            cancelButton.frame = CGRect(x: 0, y: 10, width: 100, height: 30)
            self.addSubview(cancelButton)
            
            deleteButton.setTitle("Удалить", for: .normal)
            deleteButton.isEnabled = true
            deleteButton.setTitleColor(UIColor.white, for: .normal)
            deleteButton.setTitleColor(UIColor.lightGray, for: .disabled)
            deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            deleteButton.titleLabel?.adjustsFontSizeToFitWidth = true
            deleteButton.titleLabel?.minimumScaleFactor = 0.5
            deleteButton.add(for: .touchUpInside) {
                self.deleteButton.buttonTouched()
                self.deleteSelectedMessages()
            }
            let x1: CGFloat = 120
            deleteButton.frame = CGRect(x: x1, y: 10, width: (width - 120) * 0.25, height: 30)
            self.addSubview(deleteButton)
            
            
            resendButton.setTitle("Переслать", for: .normal)
            resendButton.isEnabled = false
            if delegate.groupID == 0 {
                resendButton.isEnabled = true
            }
            resendButton.setTitleColor(UIColor.white, for: .normal)
            resendButton.setTitleColor(UIColor.lightGray, for: .disabled)
            resendButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            resendButton.titleLabel?.adjustsFontSizeToFitWidth = true
            resendButton.titleLabel?.minimumScaleFactor = 0.5
            resendButton.add(for: .touchUpInside) {
                self.resendButton.buttonTouched()
                self.resendSelectedMessages()
            }
            let x2: CGFloat = 120 + (width - 120) * 0.25
            resendButton.frame = CGRect(x: x2, y: 10, width: (width - 120) * 0.25, height: 30)
            self.addSubview(resendButton)
            
            
            editButton.setTitle("Изменить", for: .normal)
            editButton.isEnabled = dialog.canEdit
            editButton.setTitleColor(UIColor.white, for: .normal)
            editButton.setTitleColor(UIColor.lightGray, for: .disabled)
            editButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            editButton.titleLabel?.adjustsFontSizeToFitWidth = true
            editButton.titleLabel?.minimumScaleFactor = 0.5
            editButton.add(for: .touchUpInside) {
                self.editButton.buttonTouched()
                self.editSelectedMessage()
            }
            let x3: CGFloat = 120 + (width - 120) * 0.5
            editButton.frame = CGRect(x: x3, y: 10, width: (width - 120) * 0.25, height: 30)
            self.addSubview(editButton)
            
            
            copyButton.setTitle("Копировать", for: .normal)
            copyButton.isEnabled = true
            if dialog.body == "" {
                copyButton.isEnabled = false
            }
            copyButton.setTitleColor(UIColor.white, for: .normal)
            copyButton.setTitleColor(UIColor.lightGray, for: .disabled)
            copyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            copyButton.titleLabel?.adjustsFontSizeToFitWidth = true
            copyButton.titleLabel?.minimumScaleFactor = 0.5
            copyButton.add(for: .touchUpInside) {
                self.copyButton.buttonTouched()
                self.copySelectedMessage()
            }
            let x4: CGFloat = 120 + (width - 120) * 0.75
            copyButton.frame = CGRect(x: x4, y: 10, width: (width - 120) * 0.25, height: 30)
            self.addSubview(copyButton)
            
            
            show()
            
            delegate.tableView.reloadData()
            delegate.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        
        if delegate.mode == .dialog {
            self.removeFromSuperview()
            self.popover.dismiss()
            
            delegate.tableView.reloadData()
            delegate.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func show() {
        let x = delegate.width/2
        let y = delegate.view.bounds.height - 58
        
        let point = CGPoint(x: x,y: y)
        popover = Popover(options: popoverOptions)
        popover.show(self, point: point, inView: delegate.view)
        popover.dropShadow(color: UIColor.black, opacity: 0.9, offSet: CGSize(width: -1, height: 1), radius: 6)
    }
    
    func deleteSelectedMessages() {
        
        let dialogs = delegate.dialogs.filter({ $0.isSelected })
        let count = dialogs.count
        
        var forAll = true
        var spam = true
        
        for dialog in dialogs {
            if Int(Date().timeIntervalSince1970) - dialog.date >= 24 * 60 * 60 {
                forAll = false
            }
            
            if dialog.out == 1 {
                spam = false
            }
        }
        
        let alertController = UIAlertController(title: "Вы пометили \(count.messageAdder())", message: "Выберите необходимое действие:", preferredStyle: .actionSheet)
        
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        
        let action1 = UIAlertAction(title: "Удалить", style: .default) { action in
            
            self.delegate.deleteMessages()
        }
        alertController.addAction(action1)
        
        
        if forAll {
            let action2 = UIAlertAction(title: "Удалить для всех", style: .default) { action in
                
                self.delegate.deleteMessages(forAll: true)
            }
            alertController.addAction(action2)
        }
        
        
        if spam {
            let action3 = UIAlertAction(title: "Пометить как спам", style: .destructive) { action in
                
                self.delegate.deleteMessages(spam: true)
            }
            alertController.addAction(action3)
        }
        
        
        if let popoverController = alertController.popoverPresentationController {
            let bounds = self.deleteButton.bounds
            popoverController.sourceView = self.deleteButton
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.minY - 20, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.down]
        }
        
        self.delegate.present(alertController, animated: true)
    }
    
    func importantSelectedMessages() {
        
        let dialogs = delegate.dialogs.filter({ $0.isSelected })
        let count = dialogs.count
        
        var setOn = true
        var title = "Пометить как «Важное»"
        var style: UIAlertActionStyle = .default
        if dialogs.filter({ $0.important == 1 }).count == count {
            setOn = false
            title = "Снять пометку «Важное»"
            style = .destructive
        }
        
        let alertController = UIAlertController(title: "Вы пометили \(count.messageAdder())", message: "Выберите необходимое действие:", preferredStyle: .actionSheet)
        
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        
        let action1 = UIAlertAction(title: title, style: style) { action in
            
            self.delegate.setImportantMessage(setOn: setOn)
        }
        alertController.addAction(action1)
        
        
        if let popoverController = alertController.popoverPresentationController {
            let bounds = self.importantButton.bounds
            popoverController.sourceView = self.importantButton
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.minY - 20, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.down]
        }
        
        self.delegate.present(alertController, animated: true)
    }
    
    func resendSelectedMessages() {
        
        let dialogs = delegate.dialogs.filter({ $0.isSelected })
        let count = dialogs.count
        
        let alertController = UIAlertController(title: "Вы пометили \(count.messageAdder())", message: "Выберите необходимое действие:", preferredStyle: .actionSheet)
        
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        
        let action1 = UIAlertAction(title: "Переслать \(count.messageAdder())", style: .default) { action in
            
            for dialog in dialogs {
                vkSingleton.shared.forwardMessages.append("\(dialog.id)")
            }
            
            self.delegate.mode = .dialog
            self.delegate.clearSelectedMessages()
            
            self.reconfigure()
            
            self.delegate.tableView.reloadData()
            self.delegate.tableView.scrollToRow(at: self.indexPath, at: .bottom, animated: false)
            
            self.delegate.attachPanel.reconfigure()
        }
        alertController.addAction(action1)
        
        
        if let popoverController = alertController.popoverPresentationController {
            let bounds = self.resendButton.bounds
            popoverController.sourceView = self.resendButton
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.minY - 20, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.down]
        }
        
        self.delegate.present(alertController, animated: true)
    }
    
    func copySelectedMessage() {
        
        let dialogs = delegate.dialogs.filter({ $0.isSelected })
        let count = dialogs.count
        
        let alertController = UIAlertController(title: "Вы пометили \(count.messageAdder())", message: "Выберите необходимое действие:", preferredStyle: .actionSheet)
        
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        
        let action1 = UIAlertAction(title: "Копировать текст сообщения", style: .default) { action in
            
            self.delegate.mode = .dialog
            self.delegate.clearSelectedMessages()
        
            self.reconfigure()
        
            self.delegate.tableView.reloadData()
            self.delegate.tableView.scrollToRow(at: self.indexPath, at: .bottom, animated: false)
        
            UIPasteboard.general.string = self.dialog.body
            if let string = UIPasteboard.general.string {
                self.delegate.showInfoMessage(title: "Скопированное сообщение:" , msg: "\(string)")
            }
        }
        alertController.addAction(action1)
        
        
        if let popoverController = alertController.popoverPresentationController {
            let bounds = self.copyButton.bounds
            popoverController.sourceView = self.copyButton
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.minY - 20, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.down]
        }
        
        self.delegate.present(alertController, animated: true)
    }
    
    func editSelectedMessage() {
        
        let dialogs = delegate.dialogs.filter({ $0.isSelected })
        let count = dialogs.count
        
        let alertController = UIAlertController(title: "Вы пометили \(count.messageAdder())", message: "Выберите необходимое действие:", preferredStyle: .actionSheet)
        
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        
        let action1 = UIAlertAction(title: "Изменить сообщение", style: .destructive) { action in
            
            self.editButton.isEnabled = false
            self.deleteButton.isEnabled = false
            self.resendButton.isEnabled = false
            self.importantButton.isEnabled = false
            
            self.delegate.attachPanel.forwards = ""
            self.delegate.attachPanel.editID = self.dialog.id
            self.delegate.commentView.textView.text = self.dialog.body
            vkSingleton.shared.forwardMessages.removeAll(keepingCapacity: false)
            
            self.delegate.attachPanel.attachArray.removeAll(keepingCapacity: false)
            for attach in self.dialog.attachments {
                if attach.photo.count > 0 {
                    self.delegate.attachPanel.attachArray.append(attach.photo[0])
                }
                if attach.video.count > 0 {
                    self.delegate.attachPanel.attachArray.append(attach.video[0])
                }
                if attach.doc.count > 0 {
                    self.delegate.attachPanel.attachArray.append(attach.doc[0])
                }
            }
            
            self.delegate.attachPanel.reconfigure()
        }
        alertController.addAction(action1)
        
        
        if let popoverController = alertController.popoverPresentationController {
            let bounds = self.editButton.bounds
            popoverController.sourceView = self.editButton
            popoverController.sourceRect = CGRect(x: bounds.midX, y: bounds.minY - 20, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.down]
        }
        
        self.delegate.present(alertController, animated: true)
    }
}
