//
//  WorkPackage.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit
import SwiftyJSON

//also take care of CHILDREN - seems like Features have it

class WorkPackage: NSManagedObject {
    
    class func buildWorkpackages(_ projectId: NSNumber, instanceId: String, json: JSON) {
        guard let array = json["_embedded"]["elements"].array else
        {
            return
        }
        
        WorkPackage.mr_truncateAll()
        
        //there is no other way to get all possible statuses directly from API - I will check all items if they contain unknow status and if so, this status will be added to statuses for this particular project and instance
        
        for item in array {
            let _ = buildWorkPackage(projectId: projectId, instanceId: instanceId, item: item)
        }
    }
    
    class func buildWorkPackage(projectId: NSNumber, instanceId: String, item: JSON) -> Int32 {
        var wp: WorkPackage?
        
        let predicateStatuses = NSPredicate(format: "projectId = %i AND instanceId = %i", argumentArray: [projectId, instanceId])
        var statuses = Status.mr_findAll(with: predicateStatuses) as! [Status]
        if let dic = item.dictionary {
            
            if let id = dic["id"]?.int {
                let predicateWp = NSPredicate(format: "id = %i AND projectId = %i AND instanceId = %i", argumentArray: [id, projectId, instanceId])
                let wps = WorkPackage.mr_findAll(with: predicateWp) as! [WorkPackage]
            
                if wps.count > 0 {
                    wp = wps[0]
                } else {
                    wp = WorkPackage.mr_createEntity() as WorkPackage
                
                    wp!.id = Int32(id)
                    wp!.projectId = Int32(projectId)
                    wp!.instanceId = instanceId
                }
            }
        }
        
        guard let dictLinks = item["_links"].dictionary else {
            return -1
        }
        
        wp!.subject = item["subject"].stringValue
        if let value = item["parentId"].int {
            wp!.parentId = Int32(value)
        }
        if let value = item["storyPoints"].int {
            wp!.storyPoints = Int32(value)
        }
        if let value = item["remainingTime"].string {
            wp!.remainingHours = Tools.durationToInt(duration: value)
        }
        if let value = item["estimatedTime"].string {
            wp!.estimatedTime = Tools.durationToInt(duration: value)
        }
        
        if let value = item["spentTime"].int {
            wp!.spentTime = Int32(value)
        }
        
        if let value = item["percentageDone"].int {
            wp!.percentageDone = Int32(value)
        }
        
        wp!.createdAt = stringToNSDate(item["createdAt"].stringValue)
        wp!.startDate = stringToNSDate(item["startDate"].stringValue)
        wp!.updatedAt = stringToNSDate(item["updatedAt"].stringValue)
        wp!.dueDate = stringToNSDate(item["dueDate"].stringValue)
        
        if let d = dictLinks["type"]?.dictionary {
            wp!.typeTitle = d["title"]?.rawString()
        }
        
        if let d = dictLinks["priority"]?.dictionary {
            wp!.priorityTitle = d["title"]?.rawString()
        }
        
        if let d = dictLinks["status"]?.dictionary {
            wp!.statusTitle = d["title"]?.rawString()
            wp!.statusHref = d["href"]?.rawString()
            if !statuses.contains(where: { status in status.name == wp!.statusTitle }) {
                let newStatus = Status.mr_createEntity()
                newStatus?.instanceId = instanceId
                newStatus?.projectId = Int32(projectId)
                let arr = wp!.statusHref!.components(separatedBy: "/")
                newStatus?.id = Int32(arr.last!)!
                newStatus?.name = wp!.statusTitle
                newStatus?.isClosed = false
                newStatus?.isDefault = false
                newStatus?.position = (newStatus?.id)!
                newStatus?.href = wp!.statusHref
                newStatus?.allowedForNew = false
                NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
                statuses = Status.mr_findAll(with: predicateStatuses) as! [Status]
            }
        }
        
        if let d = dictLinks["author"]?.dictionary {
            wp!.authorTitle = d["title"]?.rawString()
        }
        
        if let d = dictLinks["assignee"]?.dictionary {
            if d.count == 2 {
                wp!.assigneeTitle = d["title"]?.rawString()
            }
        }
        
        if let d = dictLinks["version"]?.dictionary {
            if d.count == 2 {
                wp!.versionTitle = d["title"]?.rawString()
            }
        }
        
        if let d = dictLinks["category"]?.dictionary {
            if d.count == 2 {
                wp!.categoryTitle = d["title"]?.rawString()
            }
        }
        
        if let d = dictLinks["responsible"]?.dictionary {
            if d.count == 2 {
                wp!.responsibleTitle = d["title"]?.rawString()
            }
        }
        
        guard let dictDescription = item["description"].dictionary else {
            return -1
        }
        if let raw = dictDescription["raw"]?.rawString() {
            if raw != "null" {
                wp!.descriptionRaw = raw
            }
        }
        wp!.descriptionHtml = dictDescription["html"]?.rawString()
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        return wp!.id
    }
    
    class func stringToNSDate(_ str: String) -> NSDate? {
        
        let dateFormatter = DateFormatter()
        if (str.contains("T")) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        
        guard let date = dateFormatter.date(from: str) else {
            return nil
        }
        return date as NSDate?
    }
    
    static func getWorkPackages(projectId: NSNumber, instanceId: String) -> [WorkPackage] {
        let predicate = NSPredicate(format: "instanceId = %i AND projectId = %i", argumentArray: [instanceId, projectId.intValue])
        return WorkPackage.mr_findAllSorted(by: "id", ascending: false, with: predicate) as! [WorkPackage]
    }
    
    static func getWorkPackage(id: Int32, projectId: NSNumber, instanceId: String) -> WorkPackage? {
        let predicate = NSPredicate(format: "instanceId = %i AND projectId = %i AND id = %i", argumentArray: [instanceId, projectId.intValue, id])
        return WorkPackage.mr_findFirst(with: predicate) as WorkPackage?
    }
}
