//
//  Assignee+CoreDataClass.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 22/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


public class Assignee: NSManagedObject {
    
    class func buildAssignees(_ projectId: NSNumber, instanceId:String, json: JSON, isAssignee: Bool) {
        //if not assignee -> responsible
        let elements = json["_embedded"]["elements"]
        
        for element in elements.arrayValue {
            
            var assignee: Assignee?
            
            if let assigneeId:Int = element["id"].int {
                
                let predicate = NSPredicate(format: "instanceId = %i AND id = %i AND projectId = %i", argumentArray: [instanceId, assigneeId, projectId.intValue])
                
                let assignees = Assignee.mr_findAll(with: predicate) as! [Assignee]
                
                if assignees.count > 0 {
                    assignee = assignees[0]
                    print("\(isAssignee ? "Assignee" : "Responsible") \(assigneeId) for project \(projectId) will be updated")
                } else {
                    assignee = Assignee.mr_createEntity() as Assignee
                    assignee!.id = Int32(assigneeId)
                    assignee!.instanceId = instanceId
                    assignee!.projectId = projectId.int32Value
                    print("\(isAssignee ? "Assignee" : "Responsible") \(assigneeId) for project \(projectId) did not exist")
                }
                
                if let name:String = element["name"].string {
                    assignee!.name = name
                }
                
                if let email:String = element["email"].string {
                    assignee!.email = email
                }
                
                if let status: String = element["status"].string {
                    assignee!.status = status
                }
                
                if isAssignee {
                    assignee?.assignee = true
                }
                
                if !isAssignee {
                    assignee?.responsible = true
                }

            }
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
}
