//
//  Type+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 28/10/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension Type {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Type> {
        return NSFetchRequest<Type>(entityName: "Type");
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var position: Int32
    @NSManaged public var isDefault: Bool
    @NSManaged public var isMilestone: Bool
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var show: Bool
    @NSManaged public var projectId: Int32

}
