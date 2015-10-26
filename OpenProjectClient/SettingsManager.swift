//
//  SettingsManager.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 25/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class SettingsManager: NSObject {
    static var settings: Setting = Setting()
    
    class func getSettings() -> Setting? {
        return settings
    }
    
    class func addInstance(instance: Instance) -> Setting {
        settings.instances.append(instance)
        return settings
    }
    
    class func updateInstance(oldInstance: Instance, newInstance: Instance) {
        if let index = settings.instances.indexOf(oldInstance) {
            settings.instances[index] = newInstance
        }
    }
    
    class func deleteInstance(instance: Instance) {
        if let index = settings.instances.indexOf(instance) {
            settings.instances.removeAtIndex(index)
        }
    }
}
