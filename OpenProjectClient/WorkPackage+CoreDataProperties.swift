//
//  WorkPackage+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 27/06/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension WorkPackage {

    @NSManaged var subject: String?
    @NSManaged var id: NSNumber?
    @NSManaged var typeTitle: String?
    @NSManaged var typeHref: String?
    @NSManaged var priorityTitle: String?
    @NSManaged var priorityHref: String?
    @NSManaged var statusTitle: String?
    @NSManaged var statusHref: String?
    @NSManaged var authorTitle: String?
    @NSManaged var authorHref: String?
    @NSManaged var parentId: NSNumber?
    @NSManaged var createdAt: NSDate?
    @NSManaged var startDate: NSDate?
    @NSManaged var updatedAt: NSDate?
    @NSManaged var dueDate: NSDate?
    @NSManaged var descriptionRaw: String?
    @NSManaged var storyPoints: NSNumber?
    @NSManaged var lockVersion: NSNumber?
    @NSManaged var descriptionHtml: String?
    @NSManaged var assigneeTitle: String?
    @NSManaged var assigneeHref: String?
    @NSManaged var responsibleTitle: String?
    @NSManaged var responsibleHref: String?
    @NSManaged var projectId: NSNumber?

}
