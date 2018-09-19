//
//  RelativeCell.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 25.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

class RelativeCell: UITableViewCell {
    
    weak var delegate: UIViewController!
    
    var cellWidth: CGFloat = 0
    
    func configureCell(relatives: [Relatives], users: [UserProfile]) {
        
        self.removeAllSubviews()
        
        let titleLabel = UILabel()
        titleLabel.tag = 250
        titleLabel.text = "Родственники"
        titleLabel.font = UIFont(name: "Verdana-Bold", size: 13)!
        titleLabel.textColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1)
        titleLabel.frame = CGRect(x: 20, y: 5, width: cellWidth - 40, height: 20)
        self.addSubview(titleLabel)
        
        var topY: CGFloat = 25
        for rel in relatives {
            
            let user = users.filter({ $0.uid == "\(rel.id)" })
            if user.count > 0 {
                let typeLabel = UILabel()
                typeLabel.tag = 250
                typeLabel.text = user[0].familyConnection(relative: rel)
                typeLabel.font = UIFont(name: "Verdana", size: 13)!
                typeLabel.frame = CGRect(x: 55, y: topY, width: 70, height: 30)
                self.addSubview(typeLabel)
                
                let nameLabel = UILabel()
                nameLabel.tag = 250
                nameLabel.text = "[id\(user[0].uid)|\(user[0].firstName) \(user[0].lastName)]"
                nameLabel.textColor = nameLabel.tintColor
                nameLabel.font = UIFont(name: "Verdana", size: 13)!
                nameLabel.frame = CGRect(x: 150, y: topY, width: cellWidth - 170, height: 30)
                nameLabel.prepareTextForPublish2(delegate, cell: nil)
                self.addSubview(nameLabel)
                
                let tap = UITapGestureRecognizer()
                tap.numberOfTapsRequired = 1
                tap.add {
                    self.delegate.openProfileController(id: rel.id, name: "\(user[0].firstName) \(user[0].lastName)")
                }
                nameLabel.addGestureRecognizer(tap)
                nameLabel.isUserInteractionEnabled = true
                
                topY += 30
            }
        }
    }
    
    func getRowHeight(user: UserProfile) -> CGFloat {
        
        var topY: CGFloat = 25
        topY += CGFloat(30 * user.relatives.count)
        
        topY += 10
        
        return topY
    }
}
