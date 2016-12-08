//
//  WorkPackageActivity+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 08/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension WorkPackageActivity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkPackageActivity> {
        return NSFetchRequest<WorkPackageActivity>(entityName: "WorkPackageActivity");
    }

    @NSManaged public var comment_html: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var details: NSObject?
    @NSManaged public var id: Int32
    @NSManaged public var user_href: String?
    @NSManaged public var userName: String?

}
