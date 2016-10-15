//
//  Colors.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

enum Colors: Int {
    case darkAzureOP
    case lightAzureOP
    case paleOP
    
    func getUIColor() -> UIColor {
        switch (self) {
        case .darkAzureOP: return {
            return UIColor(netHex: 0x00466C)
            }()
        case .lightAzureOP: return {
            return UIColor(netHex: 0x3493B3)
            }()
        case .paleOP: return {
            return UIColor(netHex: 0xE7E7E7)
            }()
        }
    }
}
