//
//  WorkPackage.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class WorkPackage: NSObject {
    var id: Int
    var subject: String
    var desc: String
    
    var projectId: Int
    
    init(id: Int, subject: String, desc: String, projectId: Int) {
        self.id = id
        self.subject = subject
        self.desc = desc
        self.projectId = projectId
    }
}
