//
//  Setting.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class Instance: NSObject {
    var id: String
    var name: String
    var address: String
    var login: String
    var password: String
    
    init(name: String, address: String, login: String, password: String) {
        self.id = NSUUID().UUIDString
        self.name = name
        self.address = address
        self.login = login
        self.password = password
    }

}
