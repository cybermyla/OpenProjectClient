//
//  Priority+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 30/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension Priority {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Priority> {
        return NSFetchRequest<Priority>(entityName: "Priority");
    }

    @NSManaged public var href: String?
    @NSManaged public var id: NSNumber?
    @NSManaged public var instanceId: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var isDefault: Bool
    @NSManaged public var name: String?
    @NSManaged public var position: NSNumber?
    @NSManaged public var projectId: NSNumber?
    @NSManaged public var required: Bool
    @NSManaged public var show: Bool
    @NSManaged public var writable: Bool

}
