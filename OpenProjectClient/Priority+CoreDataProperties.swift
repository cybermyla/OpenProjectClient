//
//  Priority+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 26/07/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Priority {

    @NSManaged var required: NSNumber?
    @NSManaged var writable: NSNumber?
    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var position: NSNumber?
    @NSManaged var isDefault: NSNumber?
    @NSManaged var isActive: NSNumber?

}
