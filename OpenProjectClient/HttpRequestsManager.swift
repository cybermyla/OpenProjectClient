//
//  HttpRequestsManager.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 26/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

class HttpRequestsManager: NSObject {
    private var projects = [Project]()
    
    func getProjects() -> [Project] {
        return projects
    }
}
