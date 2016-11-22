//
//  Status+CoreDataClass.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 28/10/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit
import SwiftyJSON

public class Status: NSManagedObject {
    
    class func buildStatuses(_ projectId: NSNumber, instanceId:String, json: JSON) {
        
        let allowedValues = json["_embedded"]["schema"]["status"]["_embedded"]["allowedValues"]
        
        for element in allowedValues.arrayValue {
            
            var status: Status?
            
            if let statusId:Int = element["id"].int {
                let predicate = NSPredicate(format: "instanceId = %i AND projectId = %i AND id = %i", argumentArray: [instanceId, projectId.intValue, statusId])
                
                let statuses = Status.mr_findAll(with: predicate) as! [Status]
                
                if statuses.count > 0 {
                    status = statuses[0]
                    print("Status \(statusId) for project \(projectId) will be updated")
                } else {
                    status = Status.mr_createEntity() as Status
                    status!.id = Int32(statusId)
                    status!.projectId = projectId.int32Value
                    status!.instanceId = instanceId
                    print("Status \(statusId) for project \(projectId) did not exist")
                }
            
                if let name:String = element["name"].string {
                    status!.name = name
                }
            
                if let position: Int = element["position"].int {
                    status!.position = Int32(position)
                }
            
                if let isDefault: Bool = element["isDefault"].bool {
                    status!.isDefault = isDefault
                }
            
                if let isClosed: Bool = element["isClosed"].bool {
                    status!.isClosed = isClosed
                }
            
                if let defaultDoneRatio: Int = element["defaultDoneRatio"].int {
                    status!.defaultDoneRatio = Int32(defaultDoneRatio)
                }
            }
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func getAllStatuses(_ projectId: NSNumber, instanceId: String) -> [Status] {
        let predicate = NSPredicate(format: "projectId = %i AND instanceId = %i", argumentArray: [projectId, instanceId])
        return (Status.mr_findAllSorted(by: "id", ascending: true, with: predicate) as! [Status])
    }
}
