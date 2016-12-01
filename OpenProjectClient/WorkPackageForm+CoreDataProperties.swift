//
//  WorkPackageForm+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 30/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension WorkPackageForm {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkPackageForm> {
        return NSFetchRequest<WorkPackageForm>(entityName: "WorkPackageForm");
    }

    @NSManaged public var assignee_title: String?
    @NSManaged public var category_title: String?
    @NSManaged public var category_required: Bool
    @NSManaged public var createdAt_value: NSDate?
    @NSManaged public var createdAt_required: Bool
    @NSManaged public var description_format: String?
    @NSManaged public var description_html: String?
    @NSManaged public var description_raw: String?
    @NSManaged public var description_required: Bool
    @NSManaged public var dueDate_value: NSDate?
    @NSManaged public var dueDate_required: Bool
    @NSManaged public var estimatedTime_value: String?
    @NSManaged public var estimatedTime_required: Bool
    @NSManaged public var id_value: Int32
    @NSManaged public var id_required: Bool
    @NSManaged public var lockVersion_value: Int32
    @NSManaged public var lockVersion_required: Bool
    @NSManaged public var parent_href: String?
    @NSManaged public var parent_required: Bool
    @NSManaged public var parent_title: String?
    @NSManaged public var parentId_value: Int32
    @NSManaged public var parentId_required: Bool
    @NSManaged public var priority_href: String?
    @NSManaged public var priority_required: Bool
    @NSManaged public var priority_title: String?
    @NSManaged public var project_href: String?
    @NSManaged public var project_required: Bool
    @NSManaged public var project_title: String?
    @NSManaged public var remainingTime_value: String?
    @NSManaged public var remainingTime_required: Bool
    @NSManaged public var responsibe_required: Bool
    @NSManaged public var responsible_href: String?
    @NSManaged public var responsible_title: String?
    @NSManaged public var spentTime_value: String?
    @NSManaged public var spentTime_required: Bool
    @NSManaged public var startDate_value: NSDate?
    @NSManaged public var startDate_required: Bool
    @NSManaged public var status_href: String?
    @NSManaged public var status_required: Bool
    @NSManaged public var status_title: String?
    @NSManaged public var subject_value: String?
    @NSManaged public var subject_maxLength: Int32
    @NSManaged public var subject_minLength: Int32
    @NSManaged public var subject_required: Bool
    @NSManaged public var type_href: String?
    @NSManaged public var type_required: Bool
    @NSManaged public var type_title: String?
    @NSManaged public var updatedAt_value: NSDate?
    @NSManaged public var updatedAt_required: Bool
    @NSManaged public var version_href: String?
    @NSManaged public var version_required: Bool
    @NSManaged public var version_title: String?
    @NSManaged public var assignee_required: Bool
    @NSManaged public var assignee_name: String?
    @NSManaged public var assignee_visibility: String?
    @NSManaged public var assignee_hasDefault: Bool
    @NSManaged public var category_name: String?
    @NSManaged public var category_visibility: String?
    @NSManaged public var category_hasDefault: Bool
    @NSManaged public var createdAt_name: String?
    @NSManaged public var createdAt_visibility: String?
    @NSManaged public var description_visibility: String?
    @NSManaged public var dueDate_visibility: String?
    @NSManaged public var dueDate_name: String?
    @NSManaged public var dueDate_hasDefault: Bool
    @NSManaged public var estimatedTime_name: String?
    @NSManaged public var estimatedTime_visibility: String?
    @NSManaged public var estimatedTime_hasDefault: Bool
    @NSManaged public var id_name: String?
    @NSManaged public var id_hasDefault: Bool
    @NSManaged public var id_visibility: String?
    @NSManaged public var lockVersion_hasDefault: Bool
    @NSManaged public var lockVersion_name: String?
    @NSManaged public var lockVersion_visibility: String?
    @NSManaged public var parent_visibility: String?
    @NSManaged public var parent_hasDefault: Bool
    @NSManaged public var parent_name: String?
    @NSManaged public var parentId_visibility: String?
    @NSManaged public var parentId_hasDefault: Bool
    @NSManaged public var parentId_name: String?
    @NSManaged public var priority_visibility: String?
    @NSManaged public var priority_hasDefault: Bool
    @NSManaged public var priority_name: String?
    @NSManaged public var project_name: String?
    @NSManaged public var project_hasDefault: Bool
    @NSManaged public var project_visibility: String?
    @NSManaged public var remainingTime_name: String?
    @NSManaged public var remainingTime_visibility: String?
    @NSManaged public var remainingTime_hasDefault: Bool
    @NSManaged public var responsible_name: String?
    @NSManaged public var responsible_visibility: String?
    @NSManaged public var responsible_hasDefault: Bool
    @NSManaged public var spentTime_name: String?
    @NSManaged public var spentTime_hasDefault: Bool
    @NSManaged public var spentTime_visibility: String?
    @NSManaged public var spentTime_writable: Bool
    @NSManaged public var startDate_writable: Bool
    @NSManaged public var startDate_name: String?
    @NSManaged public var startDate_visibility: String?
    @NSManaged public var startDate_hasDefault: Bool
    @NSManaged public var status_writable: Bool
    @NSManaged public var status_name: String?
    @NSManaged public var status_visibility: String?
    @NSManaged public var status_hasDefault: Bool
    @NSManaged public var subject_name: String?
    @NSManaged public var subject_visibility: String?
    @NSManaged public var subject_hasDefault: Bool
    @NSManaged public var subject_writable: Bool
    @NSManaged public var type_name: String?
    @NSManaged public var type_visibility: String?
    @NSManaged public var type_hasDefault: Bool
    @NSManaged public var type_writable: Bool
    @NSManaged public var updatedAt_name: String?
    @NSManaged public var updatedAt_visibility: String?
    @NSManaged public var updatedAt_hasDefault: Bool
    @NSManaged public var updatedAt_writable: Bool
    @NSManaged public var version_name: String?
    @NSManaged public var version_visibility: String?
    @NSManaged public var version_hasDefault: Bool
    @NSManaged public var version_writable: Bool
    @NSManaged public var assignee_writable: Bool
    @NSManaged public var category_writable: Bool
    @NSManaged public var createdAt_hasDefault: Bool
    @NSManaged public var createdAt_writable: Bool
    @NSManaged public var description_name: String?
    @NSManaged public var description_hasDefault: Bool
    @NSManaged public var description_writable: Bool
    @NSManaged public var dueDate_writable: Bool
    @NSManaged public var estimatedTime_writable: Bool
    @NSManaged public var id_writable: Bool
    @NSManaged public var lockVersion_writable: Bool
    @NSManaged public var parent_writable: Bool
    @NSManaged public var parentId_writable: Bool
    @NSManaged public var priority_writable: Bool
    @NSManaged public var project_writable: Bool
    @NSManaged public var remainingTime_writable: Bool
    @NSManaged public var responsible_writable: Bool
    @NSManaged public var assignee_href: String?
    @NSManaged public var category_href: String?

}
