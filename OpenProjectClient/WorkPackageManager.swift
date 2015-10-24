//
//  WorkPackageManager.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class WorkPackageManager: NSObject {
    static var workpackages: [WorkPackage] = []
    
    //just for testing
    class func mockupWorkPackages(projectId: Int, count: Int) {
        for index in 1...count {
            createWorkPackage(index, subject: "Workpackage \(index) project \(projectId)", desc: "Description wp \(index)", projectId: projectId)
        }
    }
    
    class func createWorkPackage(id: Int, subject: String, desc: String, projectId: Int) {
        let wp = WorkPackage(id: id, subject: subject, desc: desc, projectId: projectId)
        workpackages.append(wp)
    }
    
    class func getWorkPackagesByProjectId(projectId: Int) -> [WorkPackage] {
        var result: [WorkPackage] = []
        for wp in workpackages {
            if (wp.projectId == projectId) {
                result.append(wp)
            }
        }
        return result
    }
}
