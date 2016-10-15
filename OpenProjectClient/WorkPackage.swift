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
    
    class func buildWorkpackages(_ projectId: NSNumber, json: JSON) {
        guard let array = json["_embedded"]["elements"].array else
        {
            return
        }
        
        for item in array {
            
            var wp: WorkPackage?
            
            if let dic = item.dictionary {

                let id = dic["id"]?.intValue
                let predicate = NSPredicate(format: "id = %i AND projectId = %i", argumentArray: [id!, projectId.intValue])
                let wps = WorkPackage.mr_findAll(with: predicate) as! [WorkPackage]
                
                if wps.count > 0 {
                    wp = wps[0]
                } else {
                    wp = WorkPackage.mr_createEntity() as WorkPackage
                    wp!.id = NSNumber(value: id!)
                    wp!.projectId = projectId
                }
            }
            
            wp!.subject = item["subject"].stringValue
            wp!.parentId = item["parentId"].intValue as NSNumber?
            wp!.storyPoints = item["storyPoints"].intValue as NSNumber?
            wp!.lockVersion = item["lockVersion"].intValue as NSNumber?
            wp!.createdAt = stringToNSDate(item["createdAt"].stringValue)
            wp!.startDate = stringToNSDate(item["startDate"].stringValue)
            wp!.updatedAt = stringToNSDate(item["updatedAt"].stringValue)
            wp!.dueDate = stringToNSDate(item["dueDate"].stringValue)

            guard let dictLinks = item["_links"].dictionary else {
                continue
            }
            
            if let d = dictLinks["type"]?.dictionary {
                wp!.typeTitle = d["title"]?.rawString()
                wp!.typeHref = d["href"]?.rawString()
            }
            
            if let d = dictLinks["priority"]?.dictionary {
                wp!.priorityTitle = d["title"]?.rawString()
                wp!.priorityHref = d["href"]?.rawString()
            }
            
            if let d = dictLinks["status"]?.dictionary {
                wp!.statusTitle = d["title"]?.rawString()
                wp!.statusHref = d["href"]?.rawString()
            }
            
            if let d = dictLinks["author"]?.dictionary {
                wp!.authorTitle = d["title"]?.rawString()
                wp!.authorHref = d["href"]?.rawString()
            }
            
            if let d = dictLinks["assignee"]?.dictionary {
                if d.count == 2 {
                    wp!.assigneeTitle = d["title"]?.rawString()
                    wp!.assigneeHref = d["href"]?.rawString()
                }
            }
            
            if let d = dictLinks["responsible"]?.dictionary {
                if d.count == 2 {
                    wp!.responsibleTitle = d["title"]?.rawString()
                    wp!.responsibleHref = d["href"]?.rawString()
                }
            }
            
            guard let dictDescription = item["description"].dictionary else {
                continue
            }
            wp!.descriptionRaw = dictDescription["raw"]?.rawString()
            wp!.descriptionHtml = dictDescription["html"]?.rawString()
        }
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    class func stringToNSDate(_ str: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let date = dateFormatter.date(from: str) else {
            return nil
        }
        return date
    }
}
