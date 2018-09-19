//
//  SwitchOptionCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 26.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class SwitchOptionCell: UITableViewCell {

    weak var delegate: UIViewController!
    
    var optSwitch = UISwitch()
    var headerLabel = UILabel()
    
    var header: String = ""
    var desc: String = ""
    
    var cellWidth: CGFloat = 0
    
    let headFont = UIFont(name: "Verdana-Bold", size: 13)!
    let descFont = UIFont(name: "Verdana", size: 13)!
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        headerLabel.tag = 250
        headerLabel.text = header
        headerLabel.font = headFont
        headerLabel.textColor = vkSingleton.shared.mainColor
        headerLabel.frame = CGRect(x: 20, y: 5, width: cellWidth - 40 - 50, height: 30)
        self.addSubview(headerLabel)
        
        optSwitch.tag = 250
        optSwitch.onTintColor = vkSingleton.shared.mainColor
        optSwitch.frame = CGRect(x: cellWidth - 70, y: 5, width: 50, height: 30)
        self.addSubview(optSwitch)
        
        if desc != "" {
            let descLabel = UILabel()
            descLabel.tag = 250
            descLabel.text = desc
            descLabel.font = descFont
            descLabel.numberOfLines = 0
            descLabel.isEnabled = false
            let size = delegate.getTextSize(text: desc, font: descFont, maxWidth: cellWidth - 40 - 60)
            descLabel.frame = CGRect(x: 20, y: 35, width: size.width, height: size.height + 5)
            self.addSubview(descLabel)
        }
    }
    
    func getRowHeight() -> CGFloat {
        
        if desc == "" {
            return 40
        }
        
        let size = delegate.getTextSize(text: desc, font: descFont, maxWidth: cellWidth - 40 - 60)
        
        return 40 + size.height + 5
    }
}
