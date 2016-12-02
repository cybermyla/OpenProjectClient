//
//  WorkPackageFormSchema+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension WorkPackageFormSchema {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkPackageFormSchema> {
        return NSFetchRequest<WorkPackageFormSchema>(entityName: "WorkPackageFormSchema");
    }

    @NSManaged public var writable: Bool
    @NSManaged public var visibility: String?
    @NSManaged public var hasDefault: Bool
    @NSManaged public var type: Int32
    @NSManaged public var name: String?
    @NSManaged public var required: Bool
    @NSManaged public var value_int: Int32
    @NSManaged public var value_string: String?
    @NSManaged public var value_title: String?
    @NSManaged public var value_href: String?
    @NSManaged public var schemaItemName: String?
    @NSManaged public var maxLength: Int32
    @NSManaged public var minLength: Int32
    @NSManaged public var value_dateTime: NSDate?
    @NSManaged public var value_str_raw: String?
    @NSManaged public var value_str_html: String?
    @NSManaged public var position: Int32
    @NSManaged public var section: Int32

}
