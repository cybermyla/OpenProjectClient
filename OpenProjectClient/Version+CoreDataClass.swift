//
//  Version+CoreDataClass.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 29/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


public class Version: NSManagedObject {
    class func buildVersions(_ projectId: NSNumber, instanceId: String, json: JSON) {

        let allowedValues = json["_embedded"]["schema"]["version"]["_embedded"]["allowedValues"]
            
        for element in allowedValues.arrayValue {
                
            var version: Version?
                
            if let versionId:Int = element["id"].int {
                let predicate = NSPredicate(format: "instanceId = %i AND projectId = %i AND id = %i", argumentArray: [instanceId, projectId.intValue, versionId])
                    
                let versions = Version.mr_findAll(with: predicate) as! [Version]
                
                if versions.count > 0 {
                    version = versions[0]
                    print("Version \(versionId) for project \(projectId) will be updated")
                } else {
                    version = Version.mr_createEntity() as Version
                    version!.id = Int32(versionId)
                    version!.projectId = projectId.int32Value
                    version!.instanceId = instanceId
                    print("Version \(versionId) for project \(projectId) did not exist")
                }
                
                if let status: String = element["status"].string {
                    version!.status = status
                }
                    
                if let href: String = element["_links"]["self"]["href"].string {
                    version!.href = href
                }
                    
                if let name: String = element["name"].string {
                    version!.name = name
                }
            }
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }

    static func getAllVersionsIdNameTuples(_ projectId: NSNumber, instanceId: String) -> [(id: Int, name: String, href: String)] {
        
        var tuples: [(id: Int, name: String, href: String)] = []
        let predicate = NSPredicate(format: "projectId = %i AND instanceId = %i AND status = %i", argumentArray: [projectId, instanceId, "open"])
        
        let versions = Version.mr_findAllSorted(by: "name", ascending: true, with: predicate) as! [Version]
        for version in versions {
            tuples.append((Int(version.id), version.name!, version.href!))
        }
        return tuples
    }
}
