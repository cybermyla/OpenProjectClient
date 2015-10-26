//
//  AppState.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class AppState: NSObject {
    var project: Project?
    var menuItem: MenuItem = MenuItem.WorkPackages
    var projectIndexPath: NSIndexPath?
    var instance: Instance?
    
    class var sharedInstance: AppState {
        struct Static {
            static let instance : AppState = AppState()
        }
        return Static.instance
    }
}
