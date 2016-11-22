//
//  Type+CoreDataClass.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 28/10/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import SwiftyJSON


public class Type: NSManagedObject {
    
    class func buildTypes(_ projectId: NSNumber, instanceId:String, json: JSON) {
        
        let allowedValues = json["_embedded"]["schema"]["type"]["_embedded"]["allowedValues"]
        
        for element in allowedValues.arrayValue {
            
            var type: Type?
            
            if let typeId:Int = element["id"].int {
                let predicate = NSPredicate(format: "instanceId = %i AND id = %i AND projectId = %i", argumentArray: [instanceId, typeId, projectId.intValue])
                
                let types = Type.mr_findAll(with: predicate) as! [Type]
                
                if types.count > 0 {
                    type = types[0]
                    print("Type \(typeId) for project \(projectId) will be updated")
                } else {
                    type = Type.mr_createEntity() as Type
                    type!.id = Int32(typeId)
                    type!.instanceId = instanceId
                    type!.projectId = projectId.int32Value
                    print("Type \(typeId) for project \(projectId) did not exist")
                }
    
                if let name:String = element["name"].string {
                    type!.name = name
                }
            
                if let color:String = element["color"].string {
                    type!.color = color
                }
    
                if let position: Int = element["position"].int {
                    type!.position = Int32(position)
                }
    
                if let isDefault: Bool = element["isDefault"].bool {
                    type!.isDefault = isDefault
                }
    
                if let isMilestone: Bool = element["isMilestone"].bool {
                    type!.isMilestone = isMilestone
                }
            }
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func getAllTypes(_ projectId: NSNumber, instanceId: String) -> [Type] {
        let predicate = NSPredicate(format: "projectId = %i AND instanceId = %i", argumentArray: [projectId, instanceId])
        return (Type.mr_findAllSorted(by: "position", ascending: true, with: predicate) as! [Type])
    }
}
