//
//  TableView.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 31.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

extension UITableView {
    func scrollToBottom(){
        
        self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - UIScreen.main.bounds.height), animated: true)
        /*DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }*/
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}
