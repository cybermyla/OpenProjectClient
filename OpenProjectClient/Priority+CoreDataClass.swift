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
    class func buildPriorities(_ projectId: Int32, instanceId:String, json: JSON) {
        var allowedValues: [JSON] = []
        
        if let allowedValuesTest = json["_embedded"]["schema"]["priority"]["_embedded"]["allowedValues"].array {
            allowedValues = allowedValuesTest
        }
        if let allowedValuesTest = json["_embedded"]["elements"].array {
            allowedValues = allowedValuesTest
        }
        
        for element in allowedValues {
            
            var priority: Priority?
            
            var newPriority = false

            if let priorityId:Int = element["id"].int {
                let predicate = NSPredicate(format: "instanceId = %i AND id = %i AND projectId = %i", argumentArray: [instanceId, priorityId, projectId])
                
                let priorities = Priority.mr_findAll(with: predicate) as! [Priority]
                
                if priorities.count > 0 {
                    priority = priorities[0]
                    print("Priority \(priorityId) for project \(projectId) will be updated")
                } else {
                    newPriority = true
                    priority = Priority.mr_createEntity() as Priority
                    priority!.id = priorityId as NSNumber?
                    priority!.projectId = projectId as NSNumber?
                    priority!.instanceId = instanceId
                    print("Priority \(priorityId) for project \(projectId) did not exist")
                }
                
                if let name:String = element["name"].string {
                    if (newPriority && priority!.name != name) {
                        print("Priority \(priorityId)-\(priority!.name) name \(priority!.name) has changed \(name)")
                    }
                    priority!.name = name
                }
                
                if let position: Int = element["position"].int {
                    if (newPriority && priority!.position != position as NSNumber?) {
                        print("Priority \(priorityId)-\(priority!.name) position \(priority!.position) has changed \(position)")
                    }
                    priority!.position = position as NSNumber?
                }
                
                if let isDefault: Bool = element["isDefault"].bool {
                    if (newPriority && priority!.isDefault != isDefault) {
                        print("Priority \(priorityId)-\(priority!.name) isDefault \(priority!.isDefault) has changed \(isDefault)")
                    }
                    priority!.isDefault = isDefault
                }
                
                if let isActive: Bool = element["isActive"].bool {
                    if (newPriority && priority!.isActive != isActive) {
                        print("Priority \(priorityId)-\(priority!.name) isActive \(priority!.isActive) has changed \(isActive)")
                    }
                    priority!.isActive = isActive
                }
                if let href: String = element["_links"]["self"]["href"].string {
                    priority!.href = href
                }
            }
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func getAllPriorities(_ projectId: NSNumber, instanceId: String) -> [Priority] {
        let predicate = NSPredicate(format: "projectId = %i AND instanceId = %i", argumentArray: [projectId, instanceId])
        return (Priority.mr_findAllSorted(by: "position", ascending: true, with: predicate) as! [Priority])
    }
    
    static func getAllIdNameTuples(_ projectId: NSNumber, instanceId: String) -> [(id: Int, name: String, href: String)] {
        
        var tuples: [(id: Int, name: String, href: String)] = []
        let predicate = NSPredicate(format: "projectId = %i AND instanceId = %i", argumentArray: [projectId, instanceId])
        let priorities = Priority.mr_findAllSorted(by: "position", ascending: true, with: predicate) as! [Priority]
        for priority in priorities {
            tuples.append((Int(priority.id!), priority.name!, priority.href!))
        }
        return tuples
    }
    
    static func getDefault(_ projectId: NSNumber, instanceId: String) -> Priority? {
        let predicate = NSPredicate(format: "projectId = %i AND instanceId = %i AND isDefault = true", argumentArray: [projectId, instanceId])
        return (Priority.mr_findFirst(with: predicate) as Priority?)
    }
}
