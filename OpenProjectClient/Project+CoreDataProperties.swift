//
//  Project+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 29/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Project {

    @NSManaged var id: NSNumber?
    @NSManaged var responsible_id: NSNumber?
    @NSManaged var project_type_id: NSNumber?
    @NSManaged var identifier: String?
    @NSManaged var parent_id: NSNumber?
    @NSManaged var desc: String?
    @NSManaged var created_on: Date?
    @NSManaged var name: String?
    @NSManaged var updated_on: Date?

}
