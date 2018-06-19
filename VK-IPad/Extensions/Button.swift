//
//  Button.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 19.06.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import UIKit

extension UIButton {
    func buttonTouched() {
        UIButton.animate(withDuration: 0.2,
                         animations: {
                            self.transform = CGAffineTransform(scaleX: 0.975, y: 0.96)
                        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.2, animations: {
                                self.transform = CGAffineTransform.identity
                            })
                        })
    }
    
    func smallButtonTouched() {
        UIButton.animate(withDuration: 0.25,
                         animations: {
                            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.92)
        },
                         completion: { finish in
                            UIButton.animate(withDuration: 0.25, animations: {
                                self.transform = CGAffineTransform.identity
                            })
        })
    }
}
