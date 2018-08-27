//
//  MessageCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 27.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    var delegate: DialogController!
    var dialog: Dialog!

    func configureLoadMoreCell() {
        
        removeAllSubviews()
        
        self.backgroundColor = delegate.tableView.backgroundColor
        
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
                self.delegate.loadMoreMessages()
            }
            self.addSubview(countButton)
        }
    }
}
