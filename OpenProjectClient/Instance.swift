//
//  Setting.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit
import SwiftyJSON

class Instance: NSManagedObject {

    class func buildInstance(_ instance: Instance, json: JSON) -> Instance {
        
        instance.instanceName = json["instanceName"].stringValue
        instance.coreVersion = json["coreVersion"].stringValue
        
        guard let linksDict = json["_links"].dictionaryObject else
        {
            return Instance()
        }
        
        if let configurationHrefRaw: NSDictionary = linksDict["configuration"] as? NSDictionary {
            instance.configurationHref = configurationHrefRaw.allValues[0] as? String
        }
        
        if let prioritiesHrefRaw: NSDictionary = linksDict["priorities"] as? NSDictionary {
            instance.prioritiesHref = prioritiesHrefRaw.allValues[0] as? String
        }
        
        if let statusesHrefRaw: NSDictionary = linksDict["statuses"] as? NSDictionary {
            instance.statusesHref = statusesHrefRaw.allValues[0] as? String
        }
        
        if let typesHrefRaw: NSDictionary = linksDict["types"] as? NSDictionary {
            instance.typesHref = typesHrefRaw.allValues[0] as? String
        }
        
        if let workPackagesHrefRaw: NSDictionary = linksDict["workPackages"] as? NSDictionary {
            instance.workPackagesHref = workPackagesHrefRaw.allValues[0] as? String
        }
        
        
        //DOES NOT WORK
        /*
         if let userHrefRaw: NSDictionary = linksDict["user"] as? NSDictionary {
         let userHrefX = userHrefRaw.allValues
         }
         
         if let userPreferencesHrefRaw: NSDictionary = linksDict["userPreferences"] as? NSDictionary {
         userPreferencesHref = userPreferencesHrefRaw.allValues[0] as! String
         }
         */
        
        return instance
    }
    static func getAllInstances() -> [Instance] {
        return Instance.mr_findAllSorted(by: "instanceName", ascending: true) as! [Instance]
    }
}
