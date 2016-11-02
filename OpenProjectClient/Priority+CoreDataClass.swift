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
    class func buildPriorities(_ projectId: NSNumber, instanceId:String, json: JSON) -> Bool {
        
        var changed = false
        
        let allowedValues = json["_embedded"]["schema"]["priority"]["_embedded"]["allowedValues"]
        
        for element in allowedValues.arrayValue {
            
            var priority: Priority?
            
            var newPriority = false

            if let priorityId:Int = element["id"].int {
                let predicate = NSPredicate(format: "instanceId = %i AND id = %i AND projectId = %i", argumentArray: [instanceId, priorityId, projectId.intValue])
                
                let priorities = Priority.mr_findAll(with: predicate) as! [Priority]
                
                if priorities.count > 0 {
                    priority = priorities[0]
                    print("Priority \(priorityId) for project \(projectId) will be updated")
                } else {
                    changed = true //this means priorities has changed - new priority - but still need to make sure that some priority has not been removed
                    newPriority = true
                    priority = Priority.mr_createEntity() as Priority
                    priority!.id = priorityId as NSNumber?
                    priority!.projectId = projectId
                    priority!.instanceId = instanceId
                    print("Priority \(priorityId) for project \(projectId) did not exist")
                }
                
                if let name:String = element["name"].string {
                    if (newPriority && priority!.name != name) {
                        print("Priority \(priorityId)-\(priority!.name) name \(priority!.name) has changed \(name)")
                        changed = true
                    }
                    priority!.name = name
                }
                
                if let position: Int = element["position"].int {
                    if (newPriority && priority!.position != position as NSNumber?) {
                        print("Priority \(priorityId)-\(priority!.name) position \(priority!.position) has changed \(position)")
                        changed = true
                    }
                    priority!.position = position as NSNumber?
                }
                
                if let isDefault: Bool = element["isDefault"].bool {
                    if (newPriority && priority!.isDefault != isDefault as NSNumber?) {
                        print("Priority \(priorityId)-\(priority!.name) isDefault \(priority!.isDefault) has changed \(isDefault)")
                        changed = true
                    }
                    priority!.isDefault = isDefault as NSNumber?
                }
                
                if let isActive: Bool = element["isActive"].bool {
                    if (newPriority && priority!.isActive != isActive as NSNumber?) {
                        print("Priority \(priorityId)-\(priority!.name) isActive \(priority!.isActive) has changed \(isActive)")
                        changed = true
                    }
                    priority!.isActive = isActive as NSNumber?
                }
            }
        }
        if changed {
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        }
        return changed
    }
    
    static func getFilterString() -> String {
        let priorities = Priority.mr_findAll(with: NSPredicate(format: "show = true")) as! [Priority]
        var list: [String] = []
        for priority in priorities {
            list.append("\u{22}\(priority.id!)\u{22}")
        }
        return "{\u{22}priority\u{22}: {\u{22}operator\u{22}: \u{22}=\u{22},\u{22}values\u{22}: [\(list.joined(separator: ","))]}}"
    }
    
    static func getAllPriorityIds(_ projectId: NSNumber, instanceId: String) -> [Int32] {
        let predicate = NSPredicate(format: "projectId = %i AND instanceId = %i", argumentArray: [projectId, instanceId])
        
        let priorities = Priority.mr_findAllSorted(by: "position", ascending: true, with: predicate) as! [Priority]
        var values: [Int32] = []
        for priority in priorities {
            values.append(priority.id as! Int32)
        }
        return values
    }
    
    static func getAllPriorities(_ projectId: NSNumber, instanceId: String) -> [Priority] {
        let predicate = NSPredicate(format: "projectId = %i AND instanceId = %i", argumentArray: [projectId, instanceId])
        return (Priority.mr_findAllSorted(by: "position", ascending: true, with: predicate) as! [Priority])
    }
}
