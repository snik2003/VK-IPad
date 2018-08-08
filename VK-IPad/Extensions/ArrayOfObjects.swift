//
//  ArrayOfObjects.swift
//  VK-IPad
//
//  Created by Сергей Никитин on 08.08.2018.
//  Copyright © 2018 Sergey Nikitin. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
