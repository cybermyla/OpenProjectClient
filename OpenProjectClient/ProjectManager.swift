//
//  ProjectManager.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class ProjectManager: NSObject {
    static var projects: [Project] = []
    
    //just for development purpose - mockup objects
    class func addProject(id: Int, name: String, desc: String) {
        let p = Project(id: id, name: name, desc: desc)
        projects.append(p)
    }
    
    class func mockupProject(projectId: Int) {
        addProject(projectId, name: "Project \(projectId)", desc: "Some description \(projectId)")
    }
    
    class func getProjects() -> [Project] {
        return projects
    }
    
}
