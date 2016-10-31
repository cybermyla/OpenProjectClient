//
//  Status+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 30/10/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension Status {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Status> {
        return NSFetchRequest<Status>(entityName: "Status");
    }

    @NSManaged public var defaultDoneRatio: Int32
    @NSManaged public var id: Int32
    @NSManaged public var isClosed: Bool
    @NSManaged public var isDefault: Bool
    @NSManaged public var name: String?
    @NSManaged public var position: Int32
    @NSManaged public var projectId: Int32
    @NSManaged public var show: Bool
    @NSManaged public var instanceId: String?

}
