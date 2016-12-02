//
//  StringObjectValue+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 02/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension StringObjectValue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StringObjectValue> {
        return NSFetchRequest<StringObjectValue>(entityName: "StringObjectValue");
    }

    @NSManaged public var schemaItemName: String?
    @NSManaged public var title: String?
    @NSManaged public var href: String?
    @NSManaged public var id: Int32

}
