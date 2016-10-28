//
//  Priority+CoreDataClass.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 26/10/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit
import SwiftyJSON

public class Priority: NSManagedObject {
    class func buildPriorities(_ projectId: NSNumber, json: JSON) {
        
        for element in json["_embedded"]["elements"].arrayValue {
            
            var priority: Priority?
            
            if let priorityId:Int = element["id"].int {
                let predicate = NSPredicate(format: "id = %i AND projectId = %i", argumentArray: [priorityId, projectId.intValue])
                
                let priorities = Priority.mr_findAll(with: predicate) as! [Priority]
                
                if priorities.count > 0 {
                    priority = priorities[0]
                    print("Priority \(priorityId) for project \(projectId) will be updated")
                } else {
                    priority = Priority.mr_createEntity() as Priority
                    priority!.id = priorityId as NSNumber?
                    priority!.projectId = projectId
                    print("Priority \(priorityId) for project \(projectId) did not exist")
                }
                
                if let name:String = element["name"].string {
                    priority!.name = name
                }
                
                if let position: Int = element["position"].int {
                    priority!.position = position as NSNumber?
                }
                
                if let isDefault: Bool = element["isDefault"].bool {
                    priority!.isDefault = isDefault as NSNumber?
                }
                
                if let isActive: Bool = element["isActive"].bool {
                    priority!.isActive = isActive as NSNumber?
                }
            }
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
}
