//
//  Priority+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 28/10/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension Priority {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Priority> {
        return NSFetchRequest<Priority>(entityName: "Priority");
    }

    @NSManaged public var id: NSNumber?
    @NSManaged public var isActive: NSNumber?
    @NSManaged public var isDefault: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var position: NSNumber?
    @NSManaged public var projectId: NSNumber?
    @NSManaged public var required: NSNumber?
    @NSManaged public var writable: NSNumber?
    @NSManaged public var show: Bool

}
