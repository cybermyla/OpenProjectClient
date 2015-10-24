//
//  Project.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class Project: NSObject {
    var id: Int?
    var name: String?
    var desc: String?
    
    init(id: Int, name: String, desc: String) {
        self.id = id
        self.name = name
        self.desc = desc
    }
}
