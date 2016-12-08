//
//  OpUser+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 08/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension OpUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OpUser> {
        return NSFetchRequest<OpUser>(entityName: "OpUser");
    }

    @NSManaged public var id: Int32
    @NSManaged public var href: String?
    @NSManaged public var status: String?
    @NSManaged public var name: String?

}
