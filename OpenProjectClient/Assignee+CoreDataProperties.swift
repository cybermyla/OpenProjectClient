//
//  Assignee+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 22/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension Assignee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assignee> {
        return NSFetchRequest<Assignee>(entityName: "Assignee");
    }

    @NSManaged public var status: String?
    @NSManaged public var id: Int32
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var projectId: Int32
    @NSManaged public var instanceId: String?
    @NSManaged public var responsible: Bool
    @NSManaged public var assignee: Bool

}
