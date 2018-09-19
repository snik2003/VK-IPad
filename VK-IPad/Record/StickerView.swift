//
//  StickerView.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 31.07.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit
import Popover

class StickerView: UIView {

    var width: CGFloat = 0
    var height: CGFloat = 0
    
    weak var delegate: UIViewController!
    weak var button: UIButton!
    weak var popover: Popover!
    
    let product1 = [97, 98, 99, 100, 101, 102, 103, 105, 106, 107, 108, 109, 110,
                    111, 112, 113, 114, 115, 116, 118, 121, 125, 126, 127, 128]
    
    let product2 = [1, 2, 3, 4, 10, 13, 14, 15, 18, 21, 22, 25, 27, 28, 29, 30, 31,
                    35, 36, 37, 39, 40, 45, 46, 48]
    
    let product3 = [49, 50, 51, 54, 57, 59, 61, 63, 65, 66, 67, 68, 71, 72, 73, 74, 75,
                    76, 82, 83, 86, 87, 88, 89, 91]
    
    let product4 = [134, 140, 145, 136, 143, 151, 148, 144, 142, 137, 135, 133, 138,
                    156, 150, 153, 149, 147, 141, 159, 164, 161, 130, 132, 160]
    
    let product5 = [215, 232, 231, 211, 214, 218, 224, 225, 209, 226, 229, 223, 210,
                    220, 217, 227, 212, 216, 219, 228, 337, 338, 221, 213, 222]
    
    var product: [Int] = []
    
    func show() {
        let popoverOptions: [PopoverOption] = [
            .type(.up),
            .cornerRadius(6),
            .color(UIColor.white),
            .blackOverlayColor(UIColor.gray.withAlphaComponent(0.75))
        ]
        
        
        self.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        let point = CGPoint(x: button.frame.midX, y: delegate.view.frame.height - 12 - button.frame.height)
        
        popover = Popover(options: popoverOptions)
        popover.show(self, point: point, inView: self.delegate.view)
    }
    
    var numProd: Int = 1 {
        willSet(newNum) {
            if newNum == 1 {
                product = product1
            } else if newNum == 2 {
                product = product2
            } else if newNum == 3 {
                product = product3
            } else if newNum == 4 {
                product = product4
            } else if newNum == 5 {
                product = product5
            }
        }
        didSet {
            self.configure()
        }
    }
    
    func configure() {
        
        removeSubviews()
        
        let bWidth = (width - 20) / 5
        for index in 0...product.count-1 {
            let sButton = UIButton()
            sButton.frame = CGRect(x: 10 + bWidth * CGFloat(index % 5) + 3, y: 10 + bWidth * CGFloat(index / 5) + 3, width: bWidth - 6, height: bWidth - 6)
            
            sButton.tag = product[index]
            let url = "https://vk.com/images/stickers/\(product[index])/256.png"
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    sButton.setImage(getCacheImage.outputImage, for: .normal)
                    sButton.add(for: .touchUpInside) {
                        if let controller = self.delegate as? RecordController {
                            controller.createComment(text: "", stickerID: sButton.tag)
                        } else if let controller = self.delegate as? VideoController {
                            controller.createComment(text: "", stickerID: sButton.tag)
                        } else if let controller = self.delegate as? TopicController {
                            controller.createComment(text: "", stickerID: sButton.tag)
                        } else if let controller = self.delegate as? DialogController {
                            controller.sendMessage(message: "", stickerID: sButton.tag)
                        }
                        
                        self.popover.dismiss()
                    }
                    self.addSubview(sButton)
                }
            }
            OperationQueue().addOperation(getCacheImage)
        }
        
        
        for index in 1...5 {
            var startX = width / 2 - 50 * 2.5 - 10
            var url = "https://vk.com/images/stickers/105/256.png"
            
            if index == 2 {
                startX = width / 2 - 50 * 1.5 - 5
                url = "https://vk.com/images/stickers/3/256.png"
            }
            
            if index == 3 {
                startX = width / 2 - 25
                url = "https://vk.com/images/stickers/63/256.png"
            }
            
            if index == 4 {
                startX = width / 2 + 25 + 5
                url = "https://vk.com/images/stickers/145/256.png"
            }
            
            if index == 5 {
                startX = width / 2 + 50 * 1.5 + 10
                url = "https://vk.com/images/stickers/231/256.png"
            }
            
            let menuButton = UIButton()
            menuButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            menuButton.frame = CGRect(x: startX, y: width + 10, width: 50, height: 50)
            
            let getCacheImage = GetCacheImage(url: url, lifeTime: .avatarImage)
            getCacheImage.completionBlock = {
                OperationQueue.main.addOperation {
                    let image = getCacheImage.outputImage
                    
                    menuButton.layer.cornerRadius = 10
                    menuButton.layer.borderColor = UIColor.gray.cgColor
                    menuButton.layer.borderWidth = 1
                    
                    if index == self.numProd {
                        menuButton.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 0.5)
                        menuButton.layer.cornerRadius = 10
                        menuButton.layer.borderColor = UIColor.init(displayP3Red: 0/255, green: 84/255, blue: 147/255, alpha: 1).cgColor
                        menuButton.layer.borderWidth = 1
                    }
                    
                    menuButton.setImage(image, for: .normal)
                    
                    menuButton.add(for: .touchUpInside) {
                        self.numProd = index
                    }
                    self.addSubview(menuButton)
                }
            }
            OperationQueue().addOperation(getCacheImage)
        }
    }
    
    func removeSubviews() {
        
        for subview in self.subviews {
            if subview is UIButton {
                subview.removeFromSuperview()
            }
        }
    }
}
