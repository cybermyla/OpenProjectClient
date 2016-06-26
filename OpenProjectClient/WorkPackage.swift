//
//  WorkPackage.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit
import SwiftyJSON

class WorkPackage: NSManagedObject {
    
    class func buildWorkpackages(json: JSON) {
        WorkPackage.MR_truncateAll()
        
        guard let array = json["_embedded"]["elements"].arrayObject else
        {
            return
        }
        
        for dataObject: AnyObject in array {
            guard let dict = dataObject as? NSDictionary else {
                continue
            }
            
            let wp = WorkPackage.MR_createEntity() as WorkPackage
            
            if let id:Int = dict["id"] as? Int {
                wp.id = NSNumber(integer: id)
            }
            
            if let subject: String = dict["subject"] as? String {
                wp.subject = subject
            }
            
            guard let dictLinks = dict["_links"] as? NSDictionary else {
                continue
            }
            
            if let d = dictLinks["type"] as? NSDictionary {
                wp.typeTitle = d["title"] as! String!
                wp.typeHref = d["href"] as! String!
            }
            
            if let d = dictLinks["priority"] as? NSDictionary {
                wp.priorityTitle = d["title"] as! String!
                wp.priorityHref = d["href"] as! String!
            }
            
            if let d = dictLinks["status"] as? NSDictionary {
                wp.statusTitle = d["title"] as! String!
                wp.statusHref = d["href"] as! String!
            }
            
            if let d = dictLinks["author"] as? NSDictionary {
                wp.authorTitle = d["title"] as! String!
                wp.authorHref = d["href"] as! String!
            }
        }
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
    }
}
