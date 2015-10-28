//
//  Instance+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 27/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Instance {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var address: String?
    @NSManaged var login: String?
    @NSManaged var password: String?

}
