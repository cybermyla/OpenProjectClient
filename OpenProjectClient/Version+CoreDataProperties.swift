//
//  Version+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 30/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension Version {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Version> {
        return NSFetchRequest<Version>(entityName: "Version");
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var href: String?
    @NSManaged public var projectId: Int32
    @NSManaged public var instanceId: String?
    @NSManaged public var status: String?

}
