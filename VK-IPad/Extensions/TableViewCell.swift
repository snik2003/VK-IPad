//
//  TableViewCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 14.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func setBadgeValue(value: Int) {
        
        for subview in self.subviews {
            if subview.tag == 250 {
                subview.removeFromSuperview()
            }
        }
        
        if value > 0 {
            let view = UIView()
            view.tag = 250
            view.backgroundColor = UIColor.white
            view.layer.borderWidth = 0.5
            view.layer.borderColor = UIColor.lightGray.cgColor
            view.layer.cornerRadius = 12
            view.frame = CGRect(x: frame.width-80, y: frame.height/2-12, width: 40, height: 24)
            self.addSubview(view)
            
            let label = UILabel()
            label.tag = 250
            label.backgroundColor = UIColor.clear
            label.text = "\(value)"
            if value >= 100 {
                label.text = "99+"
            }
            label.textColor = UIColor.gray
            label.textAlignment = .center
            label.font = UIFont(name: "TrebuchetMS-Bold", size: 14)
            label.frame = CGRect(x: frame.width-80, y: frame.height/2-10, width: 40, height: 20)
            self.addSubview(label)
        }
    }
}
