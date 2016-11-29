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
                
                if let href: String = element["_links"]["self"]["href"].string {
                    assignee?.href = href
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
    
    static func getAllAvailableAssigneesIdNameTuples(_ projectId: NSNumber, instanceId: String) -> [(id: Int, name: String, href: String)] {
        
        var tuples: [(id: Int, name: String, href: String)] = []
        let predicate = NSPredicate(format: "projectId = %i AND instanceId = %i AND status = %i AND assignee = true", argumentArray: [projectId, instanceId, "active"])

        let assignees = Assignee.mr_findAllSorted(by: "name", ascending: true, with: predicate) as! [Assignee]
        for assignee in assignees {
            tuples.append((Int(assignee.id), assignee.name!, assignee.href!))
        }
        return tuples
    }
    
    static func getAllAvailableResponsiblesdNameTuples(_ projectId: NSNumber, instanceId: String) -> [(id: Int, name: String, href: String)] {
        
        var tuples: [(id: Int, name: String, href: String)] = []
        let predicate = NSPredicate(format: "projectId = %i AND instanceId = %i AND status = %i AND responsible = true", argumentArray: [projectId, instanceId, "active"])
        
        let assignees = Assignee.mr_findAllSorted(by: "name", ascending: true, with: predicate) as! [Assignee]
        for assignee in assignees {
            tuples.append((Int(assignee.id), assignee.name!, assignee.href!))
        }
        return tuples
    }
}
