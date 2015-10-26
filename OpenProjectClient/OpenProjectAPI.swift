//
//  OpenProjectAPI.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 26/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class OpenProjectAPI: NSObject {
    private let persistencyManager : PersistencyManager
    private let httpRequestsManager : HttpRequestsManager
    private let isOnline : Bool
    
    override init() {
        self.persistencyManager = PersistencyManager()
        self.httpRequestsManager = HttpRequestsManager()
        self.isOnline = false
        
        super.init()
    }

    class var sharedInstance:OpenProjectAPI {
        struct Singleton {
            static let instance = OpenProjectAPI()
        }
        return Singleton.instance
    }
    
    func getProjects() -> [Project] {
        if isOnline {
            let projects = httpRequestsManager.getProjects()
            persistencyManager.updateProjects(projects)
        }
        return persistencyManager.getProjects()
    }
}
