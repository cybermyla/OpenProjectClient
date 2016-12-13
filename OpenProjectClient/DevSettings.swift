//
//  DevSettings.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 08/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation

class DevSettings {
    public var address: String?
    public var key: String?
    
    init() {
        
        self.address = "http://10.0.0.40"
        self.key = "93d133676d35473f14f9335f6f0323533e5a2537"
        /*
        //normal user
        self.address = "http://10.0.0.40"
        self.key = "93d133676d35473f14f9335f6f0323533e5a2537"

        self.address = "https://community.openproject.com"
        self.key = "9cfa5e3eea8f3537c50d30c2a0f6bb14a40f0217"
 
        //jenom na divani
        self.address = "http://10.0.0.40"
        self.key = "ed7524cc91c5024ad89a269546b80373c854b847"
         */
    }
}
