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

    var delegate: DialogController!
    
    var popover: Popover!
    let popoverOptions: [PopoverOption] = [
        .type(.up),
        .arrowSize(CGSize(width: 0, height: 0)),
        .showBlackOverlay(false),
        .dismissOnBlackOverlayTap(false),
        .color(vkSingleton.shared.mainColor)]
    
    var resendButton = UIButton()
    var deleteButton = UIButton()
    var importantButton = UIButton()
    
    func reconfigure() {
        
        if delegate.mode == .select {
            
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
                
                self.reconfigure()
                
                self.delegate.tableView.reloadData()
                self.delegate.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
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
                
            }
            let x3: CGFloat = 120 + (width - 120) * 0.5
            importantButton.frame = CGRect(x: x3, y: 10, width: (width - 120) * 0.5, height: 30)
            self.addSubview(importantButton)
            
            
            show()
            
            delegate.tableView.reloadData()
            delegate.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
        } else {
            self.removeFromSuperview()
            self.popover.dismiss()
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
}
