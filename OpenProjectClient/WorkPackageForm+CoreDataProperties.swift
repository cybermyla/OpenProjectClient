//
//  WorkPackageForm+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 27/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension WorkPackageForm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkPackageForm> {
        return NSFetchRequest<WorkPackageForm>(entityName: "WorkPackageForm");
    }

    @NSManaged public var parentId: Int32
    @NSManaged public var lockVersion: Int32
    @NSManaged public var status_title: String?
    @NSManaged public var status_href: String?
    @NSManaged public var responsible_title: String?
    @NSManaged public var responsible_href: String?
    @NSManaged public var category_title: String?
    @NSManaged public var category_href: String?
    @NSManaged public var parent_title: String?
    @NSManaged public var parent_href: String?
    @NSManaged public var assignee_title: String?
    @NSManaged public var assignee_href: String?
    @NSManaged public var version_title: String?
    @NSManaged public var version_href: String?
    @NSManaged public var type_title: String?
    @NSManaged public var type_href: String?
    @NSManaged public var priority_title: String?
    @NSManaged public var priority_href: String?
    @NSManaged public var project_title: String?
    @NSManaged public var project_href: String?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var subject: String?
    @NSManaged public var estimatedTime: String?
    @NSManaged public var remainingTime: String?
    @NSManaged public var dueDate: NSDate?
    @NSManaged public var description_raw: String?
    @NSManaged public var description_format: String?
    @NSManaged public var description_html: String?

}
