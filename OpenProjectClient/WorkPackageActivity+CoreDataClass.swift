//
//  WorkPackageActivity+CoreDataClass.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 07/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import SwiftyJSON

public class WorkPackageActivity: NSManagedObject {
    
    class func buildWPActivities(json: JSON) {
        
        let activities = json["_embedded"]["elements"].array
        
        WorkPackageActivity.mr_truncateAll()
        
        for element in activities! {
            
            let activity = WorkPackageActivity.mr_createEntity() as WorkPackageActivity
                
            if let value = element["createdAt"].string {
                activity.createdAt = Tools.stringToNSDate(value)
            }
            
            if let value = element["id"].int {
                activity.id = Int32(value)
            }
            
            if let value = element["comment"]["html"].string {
                activity.comment_html = value
            }
            
            if let value = element["_links"]["user"]["href"].string {
                activity.user_href = value
            }
            
            var details = [String]()
            if let arrDetails = element["details"].array {
                for detail in arrDetails {
                    if let html = detail["html"].string {
                        details.append(html)
                    }
                }
            }
            activity.details = details as NSObject?
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
}
