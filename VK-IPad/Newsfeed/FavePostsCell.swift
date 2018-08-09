//
//  FavePostsCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 23.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class FavePostsCell: UITableViewCell {
    
    var link: FaveLinks!
    
    var cellWidth: CGFloat = 0
    
    let nameFont = UIFont(name: "Verdana", size: 15)!
    let urlFont = UIFont(name: "Verdana", size: 12)!
    
    
    func configureCell() {
        
        self.removeAllSubviews()
        
        let nameLabel = UILabel()
        nameLabel.tag = 250
        nameLabel.text = link.description.replacingOccurrences(of: "\n", with: " ")
        if link.description.hasPrefix("Ссылка") {
            nameLabel.text = link.title.replacingOccurrences(of: "\n", with: " ")
        }
        nameLabel.font = nameFont
        nameLabel.numberOfLines = 1
        
        nameLabel.frame = CGRect(x: 10, y: 5, width: cellWidth - 20, height: 20)
        self.addSubview(nameLabel)
        
        
        let urlLabel = UILabel()
        urlLabel.tag = 250
        urlLabel.text = link.url
        urlLabel.font = urlFont
        urlLabel.numberOfLines = 1
        urlLabel.textColor = UIColor.blue
        urlLabel.numberOfLines = 0
        
        urlLabel.frame = CGRect(x: 10, y: 25, width: cellWidth - 20, height: 20)
        self.addSubview(urlLabel)
    }
}
