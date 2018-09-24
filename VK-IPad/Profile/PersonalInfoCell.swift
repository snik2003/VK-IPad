//
//  PersonalInfoCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 26.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class PersonalInfoCell: UITableViewCell {

    var delegate: UIViewController!
    var inform: InfoInProfile!
    
    var cellWidth: CGFloat = 0
    
    let titleFont = UIFont(name: "Verdana-Bold", size: 13)!
    let textFont = UIFont(name: "Verdana", size: 13)!
    
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        let titleLabel = UILabel()
        titleLabel.tag = 250
        titleLabel.text = inform.image
        titleLabel.font = titleFont
        titleLabel.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        titleLabel.frame = CGRect(x: 20, y: 5, width: cellWidth - 40, height: 20)
        self.addSubview(titleLabel)
        
        let detailLabel = UILabel()
        detailLabel.tag = 250
        detailLabel.text = inform.value
        detailLabel.font = textFont
        detailLabel.numberOfLines = 0
        let size = delegate.getTextSize(text: inform.value, font: textFont, maxWidth: cellWidth - 40)
        detailLabel.frame = CGRect(x: 20, y: 25, width: size.width, height: size.height + 5)
        self.addSubview(detailLabel)
    }

    func getRowHeight() -> CGFloat {
        
        let size = delegate.getTextSize(text: inform.value, font: textFont, maxWidth: cellWidth - 40)
        
        return 30 + size.height + 10
    }
}
