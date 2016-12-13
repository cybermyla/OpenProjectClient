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
    
    var self_href: String? {
        get {
            return "\"/api/v3/users/\(self.id)\""
        }
    }
    
    var show_href: String? {
        get {
            return "\"/users/\(self.id)\""
        }
    }

    class func buildOpUser(json: JSON, saveToContext: Bool) {
        let user = OpUser.mr_createEntity() as OpUser
            
        if let value = json["name"].string {
            user.name = value
        }
        
        if let value = json["_type"].string {
            user.type = value
        }
        
        if let value = json["id"].int {
            user.id = Int32(value)
        }
        
        if let value = json["login"].string {
            user.login = value
        }
        
        if let value = json["firstName"].string {
            user.firstName = value
        }
        
        if let value = json["lastName"].string {
            user.lastName = value
        }
        
        if let value = json["email"].string {
            user.email = value
        }
        
        if let value = json["admin"].bool {
            user.admin = value
        }
        
        if let value = json["avatar"].string {
            user.avatar = value
        }
        
        if let value = json["status"].string {
            user.status = value
        }
        
        if let value = json["language"].string {
            user.language = value
        }
        
        if let value = json["createdAt"].string {
            user.createdAt = Tools.stringToNSDate(value)
        }
        
        if let value = json["updatedAt"].string {
            user.updatedAt = Tools.stringToNSDate(value)
        }
        
        if saveToContext {
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        }
    }
    
    class func buildOpUsers(json: JSON) {
        OpUser.mr_truncateAll()
        if let users = json["_embedded"]["elements"].array {
            for user in users {
                buildOpUser(json: user, saveToContext: false) //saving the datacontext only once
            }
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func deleteUser(user: OpUser) {
        let predicate = NSPredicate(format: "id == %@", argumentArray: [user.id])
        OpUser.mr_deleteAll(matching: predicate)
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func getAllUsers() -> [OpUser]? {
        return OpUser.mr_findAllSorted(by: "name", ascending: true) as! [OpUser]?
    }
    
    static func getPayload(user: OpUser) -> String {
        var result = "{\"_type\": \"\(user.type)\","
        result += "\"_links\": { \"self\": { \"href\": \"/api/v3/users/\(user.id)\", \"title\": \"\(user.self_title)\" },"
        result += "\"show\": { \"href\": \"/users/\(user.id)\", \"type\": 'text/html' }, \"lock\": { \"href\": \"/api/v3/users/\(user.id)/lock\", \"method\": \"POST\" }, \"updateImmediately\": { \"href\": \"/api/v3/users/\(user.id)\", \"method\": \"PATCH\"}, \"delete\": { \"href\": \"/api/v3/users/\(user.id)\", \"method\": \"DELETE\" }, },"
        
        result += "\"id\": \(user.id), \"login\": \"\(user.login)\", \"firstName\": \"\(user.firstName)\", \"lastName\": \"\(user.lastName)\","
        result += "\"email\": \"\(user.email)\", \"admin\": \(user.admin), \"avatar\": \"\(user.avatar)\", \"status\": \"\(user.status)\", \"language\": \"\(user.language)\", \"createdAt\": \"\(Tools.nsDateToString(user.createdAt!)!)\", \"updatedAt\": \"\(Tools.nsDateToString(user.updatedAt!)!)\" }"
        return result
    }
}
