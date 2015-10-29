//
//  Colors.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

enum Colors: Int {
    case DarkAzureOP
    case LightAzureOP
    case PaleOP
    
    func getUIColor() -> UIColor {
        switch (self) {
        case DarkAzureOP: return {
            return UIColor(netHex: 0x00466C)
            }()
        case .LightAzureOP: return {
            return UIColor(netHex: 0x3493B3)
            }()
        case .PaleOP: return {
            return UIColor(netHex: 0xE7E7E7)
            }()
        }
    }
}
