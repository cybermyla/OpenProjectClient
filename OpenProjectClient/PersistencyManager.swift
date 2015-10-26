//
//  PersistencyManager.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 26/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//



import UIKit

class PersistencyManager: NSObject {
    private var projects = [Project]()
    
    override init() {
        
    }
    
    
    func getProjects() -> [Project] {
        return projects
    }
    
    func updateProjects(projects: [Project]) {
        
    }
    
}
