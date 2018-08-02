//
//  SelectAttachPanel.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 02.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Popover

class SelectAttachPanel: UIView {

    var actions: [String] = [
        "Упомянуть друга в сообщении",
        "Упомянуть сообщество в сообщении",
        "Вложить фотографию из профиля",
        "Вложить фотографию с устройства",
        "Сфотографировать на устройство",
        "Вложить видеозапись из профиля"
        ]
    
    var sizes: [String: CGSize] = [:]
    var maxWidth: CGFloat = 400
    
    var delegate: UIViewController!
    var button: UIButton!
    
    var attachPanel: AttachPanel!
    
    var popover: Popover!

    let textFont = UIFont(name: "Verdana", size: 18)!
    
    func show() {
        
        let popoverOptions: [PopoverOption] = [
            .type(.up),
            .cornerRadius(20),
            .color(UIColor.white),
            .blackOverlayColor(UIColor.gray.withAlphaComponent(0.75))
        ]
        
        
        self.configure()
        let point = CGPoint(x: button.frame.midX, y: delegate.view.frame.height - 12 - button.frame.height)
        
        popover = Popover(options: popoverOptions)
        popover.show(self, point: point, inView: self.delegate.view)
    }
    
    func configure() {
        var topY: CGFloat = 0
        var count = 0
        
        for action in actions {
            count += 1
            
            let label = UILabel()
            label.text = action
            label.textColor = label.tintColor
            label.font = textFont
            label.numberOfLines = 1
            label.textAlignment = .center
            label.minimumScaleFactor = 0.5
            label.adjustsFontSizeToFitWidth = true
            label.frame = CGRect(x: 20, y: topY, width: maxWidth - 40, height: 50)
            self.addSubview(label)
            
            let tap = UITapGestureRecognizer()
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tap)
            tap.add {
                print(action)
            
                self.popover.dismiss()
            }
            
            topY += 50
            if count < actions.count {
                drawSeparator(on: topY)
            }
        }
        
        self.frame = CGRect(x: 0, y: 0, width: maxWidth, height: topY)
    }
    
    func drawSeparator(on topY: CGFloat) {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        view.frame = CGRect(x: 10, y: topY, width: maxWidth - 20, height: 1)
        self.addSubview(view)
    }
}
