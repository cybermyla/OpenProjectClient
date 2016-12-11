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

    class func buildInstance(_ address: String, api: String, auth: String, json: JSON) {
        
        let instance = Instance.mr_createEntity() as Instance
        
        instance.instanceName = json["instanceName"].stringValue
        instance.coreVersion = json["coreVersion"].stringValue
        
        instance.address = address
        instance.apikey = api
        instance.auth = auth
        instance.id = NSUUID().uuidString
        
        guard let linksDict = json["_links"].dictionaryObject else
        {
            return
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
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    static func getAllInstances() -> [Instance] {
        return Instance.mr_findAllSorted(by: "instanceName", ascending: true) as! [Instance]
    }
    
    static func getInstanceByAddressAndKey(address: String, apiKey: String) -> Instance? {
        let predicate = NSPredicate(format: "apikey = %i AND address = %i", argumentArray: [apiKey, address])
        return Instance.mr_findFirst(with: predicate) as Instance?
    }
}
