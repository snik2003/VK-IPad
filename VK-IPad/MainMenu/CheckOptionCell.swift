//
//  CheckOptionCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 26.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import BEMCheckBox

class CheckOptionCell: UITableViewCell {

    var optCheck = BEMCheckBox()
    var descLabel = UILabel()
    
    var desc: String = ""
    
    let descFont = UIFont(name: "Verdana", size: 13)!
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        optCheck.tag = 250
        optCheck.frame = CGRect(x: 50, y: 5, width: 30, height: 30)
        optCheck.onTintColor = vkSingleton.shared.mainColor
        optCheck.onCheckColor = vkSingleton.shared.mainColor
        optCheck.lineWidth = 3.0
        self.addSubview(optCheck)
        
        descLabel.tag = 250
        descLabel.text = desc
        descLabel.font = descFont
        descLabel.frame = CGRect(x: 90, y: 5, width: 200, height: 30)
        self.addSubview(descLabel)
    }
}
