//
//  WPFilter+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension WPFilter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WPFilter> {
        return NSFetchRequest<WPFilter>(entityName: "WPFilter");
    }

    @NSManaged public var instanceId: String?
    @NSManaged public var name: String?
    @NSManaged public var priorities: NSObject?
    @NSManaged public var projectId: Int32
    @NSManaged public var statuses: NSObject?
    @NSManaged public var types: NSObject?
    @NSManaged public var selected: Bool

}
