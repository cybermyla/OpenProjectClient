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
        
        let schemaItems = json["_embedded"]["schema"]
        _ = json["_embedded"]["payload"]
        
        WorkPackageForm.mr_truncateAll()
        
        let formSchema: WorkPackageForm = WorkPackageForm.mr_createEntity()
        
        //assignee
        if let value = schemaItems["assignee"]["name"].string {
            formSchema.assignee_name = value
        }
        if let value = schemaItems["assignee"]["visibility"].string {
            formSchema.assignee_visibility = value
        }
        if let value = schemaItems["assignee"]["hasDefault"].bool {
            formSchema.assignee_hasDefault = value
        }
        if let value = schemaItems["assignee"]["writable"].bool {
            formSchema.assignee_writable = value
        }
        if let value = schemaItems["assignee"]["required"].bool {
            formSchema.assignee_required = value
        }
        //author
        //if let required = schemaItems["author"]["required"].bool {
        //    formSchema.author_required = required
        //}
        
        //category
        if let value = schemaItems["category"]["name"].string {
            formSchema.category_name = value
        }
        if let value = schemaItems["category"]["visibility"].string {
            formSchema.category_visibility = value
        }
        if let value = schemaItems["category"]["hasDefault"].bool {
            formSchema.category_hasDefault = value
        }
        if let value = schemaItems["category"]["writable"].bool {
            formSchema.category_writable = value
        }
        if let value = schemaItems["category"]["required"].bool {
            formSchema.category_required = value
        }
        
        //createdAt
        if let value = schemaItems["createdAt"]["required"].bool {
            formSchema.createdAt_required = value
        }
        if let value = schemaItems["createdAt"]["name"].string {
            formSchema.createdAt_name = value
        }
        if let value = schemaItems["createdAt"]["hasDefault"].bool {
            formSchema.createdAt_hasDefault = value
        }
        if let value = schemaItems["createdAt"]["writable"].bool {
            formSchema.createdAt_writable = value
        }
        if let value = schemaItems["createdAt"]["visibility"].string {
            formSchema.createdAt_visibility = value
        }
        
        //description
        if let value = schemaItems["description"]["required"].bool {
            formSchema.description_required = value
        }
        if let value = schemaItems["description"]["name"].string {
            formSchema.description_name = value
        }
        if let value = schemaItems["description"]["hasDefault"].bool {
            formSchema.description_hasDefault = value
        }
        if let value = schemaItems["description"]["writable"].bool {
            formSchema.description_writable = value
        }
        if let value = schemaItems["description"]["visibility"].string {
            formSchema.description_visibility = value
        }
        
        //due date
        if let value = schemaItems["dueDate"]["name"].string {
            formSchema.dueDate_name = value
        }
        if let value = schemaItems["dueDate"]["visibility"].string {
            formSchema.dueDate_visibility = value
        }
        if let value = schemaItems["dueDate"]["hasDefault"].bool {
            formSchema.dueDate_hasDefault = value
        }
        if let value = schemaItems["dueDate"]["writable"].bool {
            formSchema.dueDate_writable = value
        }
        if let value = schemaItems["dueDate"]["required"].bool {
            formSchema.dueDate_required = value
        }
        
        //estimatedTime
        if let value = schemaItems["estimatedTime"]["name"].string {
            formSchema.estimatedTime_name = value
        }
        if let value = schemaItems["estimatedTime"]["visibility"].string {
            formSchema.estimatedTime_visibility = value
        }
        if let value = schemaItems["estimatedTime"]["hasDefault"].bool {
            formSchema.estimatedTime_hasDefault = value
        }
        if let value = schemaItems["estimatedTime"]["writable"].bool {
            formSchema.estimatedTime_writable = value
        }
        if let value = schemaItems["estimatedTime"]["required"].bool {
            formSchema.estimatedTime_required = value
        }
        
        //id
        if let value = schemaItems["id"]["required"].bool {
            formSchema.id_required = value
        }
        if let value = schemaItems["id"]["name"].string {
            formSchema.id_name = value
        }
        if let value = schemaItems["id"]["visibility"].string {
            formSchema.id_visibility = value
        }
        if let value = schemaItems["id"]["writable"].bool {
            formSchema.id_writable = value
        }
        if let value = schemaItems["id"]["hasDefault"].bool {
            formSchema.id_hasDefault = value
        }
        
        //lockVersion
        if let lVersionRequired = schemaItems["lockVersion"]["required"].bool {
            formSchema.lockVersion_required = lVersionRequired
        }
        if let value = schemaItems["lockVersion"]["name"].string {
            formSchema.lockVersion_name = value
        }
        if let value = schemaItems["lockVersion"]["visibility"].string {
            formSchema.lockVersion_visibility = value
        }
        if let value = schemaItems["lockVersion"]["writable"].bool {
            formSchema.lockVersion_writable = value
        }
        if let value = schemaItems["lockVersion"]["hasDefault"].bool {
            formSchema.lockVersion_hasDefault = value
        }
        
        //parent
        if let value = schemaItems["parent"]["required"].bool {
            formSchema.parent_required = value
        }
        if let value = schemaItems["parent"]["name"].string {
            formSchema.parent_name = value
        }
        if let value = schemaItems["parent"]["visibility"].string {
            formSchema.parent_visibility = value
        }
        if let value = schemaItems["parent"]["writable"].bool {
            formSchema.parent_writable = value
        }
        if let value = schemaItems["parent"]["hasDefault"].bool {
            formSchema.parent_hasDefault = value
        }
        
        //parentId
        if let value = schemaItems["parentId"]["name"].string {
            formSchema.parentId_name = value
        }
        if let value = schemaItems["parentId"]["visibility"].string {
            formSchema.parentId_visibility = value
        }
        if let value = schemaItems["parentId"]["hasDefault"].bool {
            formSchema.parentId_hasDefault = value
        }
        if let value = schemaItems["parentId"]["writable"].bool {
            formSchema.parentId_writable = value
        }
        if let value = schemaItems["parentId"]["required"].bool {
            formSchema.parentId_required = value
        }
        
        //priority
        if let value = schemaItems["priority"]["name"].string {
            formSchema.priority_name = value
        }
        if let value = schemaItems["priority"]["visibility"].string {
            formSchema.priority_visibility = value
        }
        if let value = schemaItems["priority"]["hasDefault"].bool {
            formSchema.priority_hasDefault = value
        }
        if let value = schemaItems["priority"]["writable"].bool {
            formSchema.priority_writable = value
        }
        if let value = schemaItems["priority"]["required"].bool {
            formSchema.priority_required = value
        }
        if let value = Priority.getDefault(projectId, instanceId: instanceId) as Priority! {
            formSchema.priority_href = value.href
            formSchema.priority_title = value.name
        }
        
        //project
        if let value = schemaItems["project"]["name"].string {
            formSchema.project_name = value
        }
        if let value = schemaItems["project"]["visibility"].string {
            formSchema.project_visibility = value
        }
        if let value = schemaItems["project"]["hasDefault"].bool {
            formSchema.project_hasDefault = value
        }
        if let value = schemaItems["project"]["writable"].bool {
            formSchema.project_writable = value
        }
        if let value = schemaItems["project"]["required"].bool {
            formSchema.project_required = value
        }
        
        //remainingTime
        if let value = schemaItems["remainingTime"]["name"].string {
            formSchema.remainingTime_name = value
        }
        if let value = schemaItems["remainingTime"]["visibility"].string {
            formSchema.remainingTime_visibility = value
        }
        if let value = schemaItems["remainingTime"]["hasDefault"].bool {
            formSchema.remainingTime_hasDefault = value
        }
        if let value = schemaItems["remainingTime"]["writable"].bool {
            formSchema.remainingTime_writable = value
        }
        if let value = schemaItems["remainingTime"]["required"].bool {
            formSchema.remainingTime_required = value
        }
        
        //responsible
        if let value = schemaItems["responsible"]["name"].string {
            formSchema.responsible_name = value
        }
        if let value = schemaItems["responsible"]["visibility"].string {
            formSchema.responsible_visibility = value
        }
        if let value = schemaItems["responsible"]["hasDefault"].bool {
            formSchema.responsible_hasDefault = value
        }
        if let value = schemaItems["responsible"]["writable"].bool {
            formSchema.responsible_writable = value
        }
        if let value = schemaItems["responsible"]["required"].bool {
            formSchema.responsibe_required = value
        }
        
        //spentTime
        if let value = schemaItems["spentTime"]["name"].string {
            formSchema.spentTime_name = value
        }
        if let value = schemaItems["spentTime"]["visibility"].string {
            formSchema.spentTime_visibility = value
        }
        if let value = schemaItems["spentTime"]["hasDefault"].bool {
            formSchema.spentTime_hasDefault = value
        }
        if let value = schemaItems["spentTime"]["writable"].bool {
            formSchema.spentTime_writable = value
        }
        if let value = schemaItems["spentTime"]["required"].bool {
            formSchema.spentTime_required = value
        }
        
        //startDate
        if let value = schemaItems["startDate"]["name"].string {
            formSchema.startDate_name = value
        }
        if let value = schemaItems["startDate"]["visibility"].string {
            formSchema.startDate_visibility = value
        }
        if let value = schemaItems["startDate"]["hasDefault"].bool {
            formSchema.startDate_hasDefault = value
        }
        if let value = schemaItems["startDate"]["writable"].bool {
            formSchema.startDate_writable = value
        }
        if let value = schemaItems["startDate"]["required"].bool {
            formSchema.startDate_required = value
        }
        
        //status
        if let value = schemaItems["status"]["name"].string {
            formSchema.status_name = value
        }
        if let value = schemaItems["status"]["visibility"].string {
            formSchema.status_visibility = value
        }
        if let value = schemaItems["status"]["hasDefault"].bool {
            formSchema.status_hasDefault = value
        }
        if let value = schemaItems["status"]["writable"].bool {
            formSchema.status_writable = value
        }
        if let value = schemaItems["status"]["required"].bool {
            formSchema.status_required = value
        }
        if let value = Status.getDefault(projectId, instanceId: instanceId) as Status! {
            formSchema.status_href = value.href
            formSchema.status_title = value.name
        }
        
        //subject
        if let value = schemaItems["subject"]["name"].string {
            formSchema.subject_name = value
        }
        if let value = schemaItems["subject"]["visibility"].string {
            formSchema.subject_visibility = value
        }
        if let value = schemaItems["subject"]["hasDefault"].bool {
            formSchema.subject_hasDefault = value
        }
        if let value = schemaItems["subject"]["writable"].bool {
            formSchema.subject_writable = value
        }
        if let value = schemaItems["subject"]["required"].bool {
            formSchema.subject_required = value
        }
        if let required = schemaItems["subject"]["required"].bool {
            formSchema.subject_required = required
        }
        if let length = schemaItems["subject"]["maxLength"].int {
            formSchema.subject_maxLength = Int32(length)
        }
        if let length = schemaItems["subject"]["minLength"].int {
            formSchema.subject_minLength = Int32(length)
        }
        
        //type
        if let value = schemaItems["type"]["name"].string {
            formSchema.type_name = value
        }
        if let value = schemaItems["type"]["visibility"].string {
            formSchema.type_visibility = value
        }
        if let value = schemaItems["type"]["hasDefault"].bool {
            formSchema.type_hasDefault = value
        }
        if let value = schemaItems["type"]["writable"].bool {
            formSchema.type_writable = value
        }
        if let value = schemaItems["type"]["required"].bool {
            formSchema.type_required = value
        }
        if let value = Type.getDefault(projectId, instanceId: instanceId) as Type! {
            formSchema.type_href = value.href
            formSchema.type_title = value.name
        }
        
        //updatedAt
        if let value = schemaItems["updatedAt"]["name"].string {
            formSchema.updatedAt_name = value
        }
        if let value = schemaItems["updatedAt"]["visibility"].string {
            formSchema.updatedAt_visibility = value
        }
        if let value = schemaItems["updatedAt"]["hasDefault"].bool {
            formSchema.updatedAt_hasDefault = value
        }
        if let value = schemaItems["updatedAt"]["writable"].bool {
            formSchema.updatedAt_writable = value
        }
        if let value = schemaItems["updatedAt"]["required"].bool {
            formSchema.updatedAt_required = value
        }
        
        //version
        if let value = schemaItems["version"]["name"].string {
            formSchema.version_name = value
        }
        if let value = schemaItems["version"]["visibility"].string {
            formSchema.version_visibility = value
        }
        if let value = schemaItems["version"]["hasDefault"].bool {
            formSchema.version_hasDefault = value
        }
        if let value = schemaItems["version"]["writable"].bool {
            formSchema.version_writable = value
        }
        if let value = schemaItems["version"]["required"].bool {
            formSchema.version_required = value
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
            "\"lockVersion\": \(wp.lockVersion_value)," +
            "\"subject\": \(varToString(wp.subject_value))," +
            //"\"percentageDone\": \(wp.)," +
            "\"estimatedTime\": \(varToString(wp.estimatedTime_value))," +
            "\"description\": {\"format\": \"textile\",\"raw\": \(varToString(wp.description_raw)),\"html\": \(varToString(wp.description_html))}," +
            "\"parentId\": \(intToString(wp.parentId_value as NSNumber?))," +
            "\"startDate\": \(dateToString(wp.startDate_value as Date?))," +
            "\"dueDate\": \(dateToString(wp.dueDate_value as Date?))," +
            "\"remainingTime\": \(varToString(wp.remainingTime_value))" +
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
        wpf.subject_value = str
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
