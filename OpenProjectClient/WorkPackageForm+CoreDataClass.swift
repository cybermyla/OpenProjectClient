//
//  WorkPackageForm+CoreDataClass.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 27/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

public class WorkPackageForm: NSManagedObject {
    
    class func buildWorkPackageCreateFormPayload(_ projectId: NSNumber, instanceId:String, json: JSON) {
        
        let payloadItems = json["_embedded"]["payload"]
        
        WorkPackageForm.mr_truncateAll()
        
        let payload: WorkPackageForm = WorkPackageForm.mr_createEntity()

        if let pId = payloadItems["parentId"].int {
            payload.parentId = Int32(pId)
        }
        if let lVersion = payloadItems["lockVersion"].int {
            payload.lockVersion = Int32(lVersion)
        }
        if let sDate = payloadItems["startDate"].string {
            payload.startDate = convertStringToNSDate(str: sDate)
        }
        if let subj = payloadItems["subject"].string {
            payload.subject = subj
        }
        if let estTime = payloadItems["estimatedTime"].string {
            payload.estimatedTime = nil
        }
        if let rmnTime = payloadItems["remainingTime"].string {
            payload.remainingTime = nil
        }
        if let due = payloadItems["dueDate"].string {
            payload.dueDate = convertStringToNSDate(str: due)
        }
        
        if let href = payloadItems["_links"]["status"]["href"].string {
            if let title = payloadItems["_links"]["status"]["title"].string {
                payload.status_href = href
                payload.status_title = title
            }
        }
        
        if let href = payloadItems["_links"]["responsible"]["href"].string {
            if let title = payloadItems["_links"]["responsible"]["title"].string {
                payload.responsible_href = href
                payload.responsible_title = title
            }
        }
        
        if let href = payloadItems["_links"]["category"]["href"].string {
            if let title = payloadItems["_links"]["category"]["title"].string {
                payload.category_href = href
                payload.category_title = title
            }
        }
        
        if let href = payloadItems["_links"]["parent"]["href"].string {
            if let title = payloadItems["_links"]["parent"]["title"].string {
                payload.parent_href = href
                payload.parent_title = title
            }
        }
        
        if let href = payloadItems["_links"]["assignee"]["href"].string {
            if let title = payloadItems["_links"]["assignee"]["title"].string {
                payload.assignee_href = href
                payload.assignee_title = title
            }
        }
        
        if let href = payloadItems["_links"]["version"]["href"].string {
            if let title = payloadItems["_links"]["version"]["title"].string {
                payload.version_href = href
                payload.version_title = title
            }
        }
        
        if let href = payloadItems["_links"]["type"]["href"].string {
            if let title = payloadItems["_links"]["type"]["title"].string {
                payload.type_href = href
                payload.type_title = title
            }
        }
        
        if let href = payloadItems["_links"]["priority"]["href"].string {
            if let title = payloadItems["_links"]["priority"]["title"].string {
                payload.priority_href = href
                payload.priority_title = title
            }
        }
        
        if let href = payloadItems["_links"]["project"]["href"].string {
            if let title = payloadItems["_links"]["project"]["title"].string {
                payload.project_href = href
                payload.project_title = title
            }
        }
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func convertStringToNSDate(str: String) -> NSDate? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from:str)
        return date as NSDate?
    }
    
    static func payload() -> String {
        let wp = WorkPackageForm.mr_findFirst() as WorkPackageForm
        
        return "{" +
            "\"_links\": {" +
            "\"type\": {\"href\": \(varToString(wp.type_href))}," +
            "\"status\": {\"href\": \(varToString(wp.status_href))}," +
            "\"assignee\": {\"href\": \(varToString(wp.assignee_href))}," +
            "\"responsible\": {\"href\": \(varToString(wp.responsible_href))}," +
            "\"category\": {\"href\": \(varToString(wp.category_href)) }," +
            "\"version\": {\"href\": \(varToString(wp.version_href))}," +
            "\"priority\": {\"href\": \(varToString(wp.priority_href))}," +
            "\"parent\": {\"href\": \(varToString(wp.priority_href))}," +
            //"\"costObject\": {\"href\": \(varToString(costObject))}" +
            "}," +
            "\"lockVersion\": \(wp.lockVersion)," +
            "\"subject\": \(varToString(wp.subject))," +
            //"\"percentageDone\": \(wp.)," +
            "\"estimatedTime\": \(varToString(wp.estimatedTime))," +
            "\"description\": {\"format\": \"textile\",\"raw\": \(varToString(wp.description_raw)),\"html\": \(varToString(wp.description_html))}," +
            "\"parentId\": \(intToString(wp.parentId as NSNumber?))," +
            "\"startDate\": \(dateToString(wp.startDate as Date?))," +
            "\"dueDate\": \(dateToString(wp.dueDate as Date?))," +
            "\"remainingTime\": \(varToString(wp.remainingTime))" +
        "}"
    }
    
    static func varToString(_ str: String?) -> String {
        if let s = str {
            return "\"\(s)\""
        } else {
            return "null"
        }
    }
    
    static func intToString(_ int: NSNumber?) -> String {
        if let i = int {
            return "\(i)"
        } else {
            return "null"
        }
    }
    
    static func dateToString(_ date: Date?) -> String {
        if date != nil {
            return "SOMEDATE"
        } else {
            return "null"
        }
    }
    
    static func updateSubject(str: String) {
        let wpf = WorkPackageForm.mr_findFirst() as WorkPackageForm
        wpf.subject = str
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func updateDescription(str: String) {
        let wpf = WorkPackageForm.mr_findFirst() as WorkPackageForm
        wpf.description_raw = str
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func updateType(title: String, href: String) {
        let wpf = WorkPackageForm.mr_findFirst() as WorkPackageForm
        wpf.type_title = title
        wpf.type_href = href
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func updatePriority(title: String, href: String) {
        let wpf = WorkPackageForm.mr_findFirst() as WorkPackageForm
        wpf.priority_title = title
        wpf.priority_href = href
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func updateStatus(title: String, href: String) {
        let wpf = WorkPackageForm.mr_findFirst() as WorkPackageForm
        wpf.status_title = title
        wpf.status_href = href
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func updateAssignee(title: String?, href: String?) {
        let wpf = WorkPackageForm.mr_findFirst() as WorkPackageForm
        wpf.assignee_title = title
        wpf.assignee_href = href
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func updateResponsible(title: String?, href: String?) {
        let wpf = WorkPackageForm.mr_findFirst() as WorkPackageForm
        wpf.responsible_title = title
        wpf.responsible_href = href
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func updateVersion(title: String?, href: String?) {
        let wpf = WorkPackageForm.mr_findFirst() as WorkPackageForm
        wpf.version_title = title
        wpf.version_href = href
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
}
