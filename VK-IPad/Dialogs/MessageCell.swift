//
//  MessageCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 27.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import BEMCheckBox

class MessageCell: UITableViewCell {

    var delegate: DialogController!
    var dialog: Dialog!
    var indexPath: IndexPath!
    
    var maxWidth: CGFloat {
        return 2 / 3 * delegate.width
    }
    
    func configureCell(calcHeight: Bool) -> CGFloat {
        
        removeAllSubviews()
        
        self.backgroundColor = vkSingleton.shared.dialogColor
        
        let view = MessageView()
        view.tag = 250
        view.delegate = delegate
        view.cell = self
        view.dialog = dialog
        view.maxWidth = maxWidth
        view.indexPath = indexPath
        
        let height = view.configureView(calcHeight: calcHeight)
        
        if dialog.important == 1 {
            let label = UILabel()
            label.tag = 250
            label.text = "«Важное»"
            label.textAlignment = .center
            label.textColor = UIColor.red
            label.font = UIFont(name: "Verdana", size: 12)
            label.numberOfLines = 1
            label.isEnabled = true
            
            var leftX: CGFloat = 0
            if dialog.out == 0 {
                leftX = maxWidth + 60
            }
            label.frame = CGRect(x: leftX, y: 15, width: delegate.width - maxWidth - 60, height: 20)
            self.addSubview(label)
            
        }
        
        if delegate.mode == .select && !calcHeight {
            let markCheck = BEMCheckBox()
            markCheck.tag = 250
            markCheck.onTintColor = vkSingleton.shared.mainColor
            markCheck.onCheckColor = vkSingleton.shared.mainColor
            markCheck.lineWidth = 3
            markCheck.on = dialog.isSelected
            
            markCheck.add(for: .valueChanged) {
                self.dialog.isSelected = markCheck.on
                self.delegate.tableView.reloadRows(at: [self.indexPath], with: .automatic)
                
                let dialogs = self.delegate.dialogs.filter({ $0.isSelected })
                let count = dialogs.count
                
                if count > 0 {
                    self.delegate.panel.deleteButton.setTitle("Удалить (\(count))", for: .normal)
                    self.delegate.panel.resendButton.setTitle("Переслать (\(count))", for: .normal)
                    self.delegate.panel.importantButton.setTitle("Пометить как «Важное» (\(count))", for: .normal)
                    if dialogs.filter({ $0.important == 1 }).count == count {
                        self.delegate.panel.importantButton.setTitle("Снять пометку «Важное» (\(count))", for: .normal)
                    }
                    
                    self.delegate.panel.deleteButton.isEnabled = true
                    self.delegate.panel.resendButton.isEnabled = true
                    self.delegate.panel.importantButton.isEnabled = true
                } else {
                    self.delegate.panel.deleteButton.setTitle("Удалить", for: .normal)
                    self.delegate.panel.resendButton.setTitle("Переслать", for: .normal)
                    self.delegate.panel.importantButton.setTitle("Пометить как «Важное»", for: .normal)
                    
                    self.delegate.panel.deleteButton.isEnabled = false
                    self.delegate.panel.resendButton.isEnabled = false
                    self.delegate.panel.importantButton.isEnabled = false
                }
            }
            
            var leftX: CGFloat = 0
            if dialog.out == 0 {
                leftX = delegate.width - 30 - 20
            } else {
                leftX = 20
            }
            markCheck.frame = CGRect(x: leftX, y: height/2 - 20, width: 30, height: 30)
            
            let fadeView = UIView()
            fadeView.tag = 250
            if dialog.isSelected {
                fadeView.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.75)
            } else {
                fadeView.backgroundColor = UIColor.clear
            }
            fadeView.frame = CGRect(x: 0, y: 0, width: delegate.width, height: height)
            self.addSubview(fadeView)
            
            self.addSubview(markCheck)
        }
        
        if delegate.mode == .edit && !calcHeight {
            let markCheck = BEMCheckBox()
            markCheck.tag = 250
            markCheck.onTintColor = vkSingleton.shared.mainColor
            markCheck.onCheckColor = vkSingleton.shared.mainColor
            markCheck.lineWidth = 3
            markCheck.on = true
            markCheck.isEnabled = false
            
            var leftX: CGFloat = 0
            if dialog.out == 0 {
                leftX = delegate.width - 30 - 20
            } else {
                leftX = 20
            }
            markCheck.frame = CGRect(x: leftX, y: height/2 - 20, width: 30, height: 30)
            
            let fadeView = UIView()
            fadeView.tag = 250
            if dialog.isSelected {
                fadeView.backgroundColor = vkSingleton.shared.backColor.withAlphaComponent(0.75)
            } else {
                fadeView.backgroundColor = UIColor.clear
            }
            fadeView.frame = CGRect(x: 0, y: 0, width: delegate.width, height: height)
            self.addSubview(fadeView)
            if dialog.isSelected {
                self.addSubview(markCheck)
            }
        }
        
        if dialog.readState == 0 && delegate.source == .all {
            self.backgroundColor = UIColor.purple.withAlphaComponent(0.2)
        } else {
            self.backgroundColor = delegate.tableView.backgroundColor
        }
        
        return height
    }
    
    func configureLoadMoreCell() {
        
        removeAllSubviews()
        
        self.backgroundColor = vkSingleton.shared.dialogColor
        
        if delegate.dialogs.count < delegate.totalCount {
            
            let total = delegate.totalCount - delegate.dialogs.count
            var count = delegate.count
            if total < count { count = total }
            
            let countButton = UIButton()
            countButton.tag = 250
            countButton.setTitle("Загрузить еще \(count) из \(total) сообщений", for: .normal)
            countButton.setTitleColor(countButton.titleLabel?.tintColor, for: .normal)
            countButton.contentMode = .center
            countButton.titleLabel?.font = UIFont(name: "Verdana", size: 14)!
            countButton.titleLabel?.adjustsFontSizeToFitWidth = true
            countButton.titleLabel?.minimumScaleFactor = 0.5
            countButton.frame = CGRect(x: 0, y: 10, width: delegate.view.bounds.width, height: 30)
            countButton.add(for: .touchUpInside) {
                countButton.buttonTouched()
                if self.delegate.source == .all {
                    self.delegate.loadMoreMessages()
                } else if self.delegate.source == .important {
                    self.delegate.loadMoreImportantMessages()
                }
            }
            self.addSubview(countButton)
        }
    }
}
