//
//  StringObjectValue+CoreDataClass.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


public class StringObjectValue: NSManagedObject {
    
    class func buildStringObjectValue(json: JSON, schemaItemName: String) {
        let arrValues = json["_embedded"]["schema"][schemaItemName]["_links"]["allowedValues"].arrayValue

        var id: Int32 = 0
        for arrValue in arrValues {
            
            let soValue = StringObjectValue.mr_createEntity()
            soValue?.schemaItemName = schemaItemName
            soValue?.id = id
            if let value = arrValue["href"].string {
                soValue?.href = value
            }
            if let value = arrValue["title"].string {
                soValue?.title = value
            }
            id += 1
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func getAllIdNameTuples(schemaItemName: String) -> [(id: Int, name: String, href: String)] {
        
        var tuples: [(id: Int, name: String, href: String)] = []
        let predicate = NSPredicate(format: "schemaItemName = %i", argumentArray: [schemaItemName])
        let items = StringObjectValue.mr_findAllSorted(by: "id", ascending: true, with: predicate) as! [StringObjectValue]
        for item in items {
            tuples.append((Int(item.id), item.title!, item.href!))
        }
        return tuples
    }
}
