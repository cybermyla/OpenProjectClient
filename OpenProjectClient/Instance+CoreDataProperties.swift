//
//  Instance+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 20/06/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Instance {

    @NSManaged var address: String?
    @NSManaged var apikey: String?
    @NSManaged var auth: String?
    @NSManaged var id: String?
    @NSManaged var configurationHref: String?
    @NSManaged var coreVersion: String?
    @NSManaged var instanceName: String?
    @NSManaged var prioritiesHref: String?
    @NSManaged var statusesHref: String?
    @NSManaged var typesHref: String?
    @NSManaged var workPackagesHref: String?

}
