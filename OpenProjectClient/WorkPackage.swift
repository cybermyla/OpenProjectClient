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
    
    class func buildWorkpackages(projectId: NSNumber, json: JSON) {
        
        guard let array = json["_embedded"]["elements"].arrayObject else
        {
            return
        }
        
        for dataObject: AnyObject in array {
            guard let dict = dataObject as? NSDictionary else {
                continue
            }
            
            var wp: WorkPackage?
            
            if let id:Int = dict["id"] as? Int {
                let predicate = NSPredicate(format: "id = %d AND projectId = %d" , argumentArray: [id, projectId])
                
                let wps = WorkPackage.MR_findAllWithPredicate(predicate) as! [WorkPackage]
                
                if wps.count > 0 {
                    wp = wps[0]
                } else {
                    wp = WorkPackage.MR_createEntity() as WorkPackage
                    wp!.id = NSNumber(integer: id)
                    wp!.projectId = projectId
                }
            }
            
            if let subject: String = dict["subject"] as? String {
                wp!.subject = subject
            }
            
            if let parentId: Int = dict["parentId"] as? Int {
                wp!.parentId = NSNumber(integer: parentId)
            }
            
            if let storyPoints: Int = dict["storyPoints"] as? Int {
                wp!.storyPoints = NSNumber(integer: storyPoints)
            }
            
            if let lockVersion: Int = dict["lockVersion"] as? Int {
                wp!.lockVersion = NSNumber(integer: lockVersion)
            }
            
            if let date: String = dict["createdAt"] as? String {
                wp!.createdAt = stringToNSDate(date)
            }
            
            if let date: String = dict["startDate"] as? String {
                wp!.startDate = stringToNSDate(date)
            }
            
            if let date: String = dict["updatedAt"] as? String {
                wp!.updatedAt = stringToNSDate(date)
            }
            
            if let date: String = dict["dueDate"] as? String {
                wp!.dueDate = stringToNSDate(date)
            }

            guard let dictLinks = dict["_links"] as? NSDictionary else {
                continue
            }
            
            if let d = dictLinks["type"] as? NSDictionary {
                wp!.typeTitle = d["title"] as! String!
                wp!.typeHref = d["href"] as! String!
            }
            
            if let d = dictLinks["priority"] as? NSDictionary {
                wp!.priorityTitle = d["title"] as! String!
                wp!.priorityHref = d["href"] as! String!
            }
            
            if let d = dictLinks["status"] as? NSDictionary {
                wp!.statusTitle = d["title"] as! String!
                wp!.statusHref = d["href"] as! String!
            }
            
            if let d = dictLinks["author"] as? NSDictionary {
                wp!.authorTitle = d["title"] as! String!
                wp!.authorHref = d["href"] as! String!
            }
            
            if let d = dictLinks["assignee"] as? NSDictionary {
                if d.count == 2 {
                    wp!.assigneeTitle = d["title"] as! String!
                    wp!.assigneeHref = d["href"] as! String!
                }
            }
            
            if let d = dictLinks["responsible"] as? NSDictionary {
                if d.count == 2 {
                    wp!.responsibleTitle = d["title"] as! String!
                    wp!.responsibleHref = d["href"] as! String!
                }
            }
            
            guard let dictDescription = dict["description"] as? NSDictionary else {
                continue
            }
            
            if let raw = dictDescription["raw"] as? String {
                wp!.descriptionRaw = raw
            }
            
            if let html = dictDescription["html"] as? String {
                wp!.descriptionHtml = html
            }
        }
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
    
    class func stringToNSDate(str: String) -> NSDate? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        guard let date = dateFormatter.dateFromString(str) else {
            return nil
        }
        return date
    }
}
