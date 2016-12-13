//
//  OpUser+CoreDataProperties.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 13/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


extension OpUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OpUser> {
        return NSFetchRequest<OpUser>(entityName: "OpUser");
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var status: String?
    @NSManaged public var type: String?
    @NSManaged public var login: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var email: String?
    @NSManaged public var admin: Bool
    @NSManaged public var avatar: String?
    @NSManaged public var language: String?
    @NSManaged public var createdAt: NSDate?
    @NSManaged public var updatedAt: NSDate?
    @NSManaged public var self_title: String?

}
