//
//  OpUser+CoreDataClass.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 08/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


public class OpUser: NSManagedObject {
    
    class func buildOpUser(json: JSON) {
        let user = OpUser.mr_createEntity() as OpUser
            
        if let value = json["name"].string {
            user.name = value
        }
        
        if let value = json["_links"]["self"]["href"].string {
            user.href = value
        }
        
        if let value = json["id"].int {
            user.id = Int32(value)
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    class func buildOpUsers(json: JSON) {
        OpUser.mr_truncateAll()
        if let users = json["_embedded"]["elements"].array {
            for user in users {
                buildOpUser(json: user)
            }
        }
    }
}
