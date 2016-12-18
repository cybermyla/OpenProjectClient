//
//  WorkPackage+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 18/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension WorkPackage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkPackage> {
        return NSFetchRequest<WorkPackage>(entityName: "WorkPackage");
    }

    @NSManaged public var activitiesHref: String?
    @NSManaged public var addCommentHref: String?
    @NSManaged public var assigneeTitle: String?
    @NSManaged public var authorTitle: String?
    @NSManaged public var categoryTitle: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var descriptionHtml: String?
    @NSManaged public var descriptionRaw: String?
    @NSManaged public var dueDate: NSDate?
    @NSManaged public var estimatedTime: Int32
    @NSManaged public var id: Int32
    @NSManaged public var instanceId: String?
    @NSManaged public var parentId: Int32
    @NSManaged public var percentageDone: Int32
    @NSManaged public var priorityTitle: String?
    @NSManaged public var projectId: Int32
    @NSManaged public var remainingHours: Int32
    @NSManaged public var responsibleTitle: String?
    @NSManaged public var spentTime: String?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var statusHref: String?
    @NSManaged public var statusTitle: String?
    @NSManaged public var storyPoints: Int32
    @NSManaged public var subject: String?
    @NSManaged public var typeTitle: String?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var versionTitle: String?
    @NSManaged public var watchHref: String?

}
