//
//  Priority.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 25/07/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class Priority: NSManagedObject {
    class func buildPriorities(_ json: JSON) {
        
        Priority.mr_truncateAll()
        
        for item in json["projects"].arrayValue {
            let priority = Priority.mr_createEntity() as Priority
            /*
            if let projectId:Int = item["id"].int{
                priority.id = NSNumber(integer: projectId)
            }
            if let responsibleId:Int = item["responsible_id"].int{
                priority.responsible_id = NSNumber(integer: responsibleId)
            }
            if let projectTypeId:Int = item["project_type_id"].int{
                priority.project_type_id = NSNumber(integer: projectTypeId)
            }
            if let identifier:String = item["identifier"].string {
                project.identifier = identifier
            }
            if let parentId:Int = item["parent_id"].int {
                project.parent_id = NSNumber(integer: parentId)
            }
            if let desc:String = item["description"].string {
                project.desc = desc
            }
            if let name:String = item["name"].string {
                project.name = name
            }
 */
        }
        
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
}
