//
//  Project.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit
import SwiftyJSON

class Project: NSManagedObject {
    
    class func buildProjects(_ json: JSON) {
        
        Project.mr_truncateAll()
        
        for item in json["projects"].arrayValue {
            let project = Project.mr_createEntity() as Project
            
            if let projectId:Int = item["id"].int {
                project.id = NSNumber(value: projectId)
            }
            if let responsibleId:Int = item["responsible_id"].int {
                project.responsible_id = NSNumber(value: responsibleId)
            }
            if let projectTypeId:Int = item["project_type_id"].int {
                project.project_type_id = NSNumber(value: projectTypeId)
            }
            if let identifier:String = item["identifier"].string {
                project.identifier = identifier
            }
            if let parentId:Int = item["parent_id"].int {
                project.parent_id = NSNumber(value: parentId)
            }
            if let desc:String = item["description"].string {
                project.desc = desc
            }
            if let name:String = item["name"].string {
                project.name = name
            }
        }
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
}
