//
//  NewWpForm.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 25/07/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation

class NewWpForm {
    var typeLink: String?
    var statusLink: String?
    var assigneeLink: String?
    var responsibleLink: String?
    var categoryLink: String?
    var versionLink: String?
    var priorityLink: String?
    var parentLink: String?
    var costObject: String?
    var lockVersion: Int?
    var subject: String?
    var percentageDone: Int?
    var estimatedTime: String?
    var descriptionFormat: String?
    var descriptionRaw: String?
    var descriptionHtml: String?
    var parentId: Int?
    var startDate: Date?
    var dueDate: Date?
    var remainingTime: String?
    
    func payload() -> String {
        return "{" +
            "\"_links\": {" +
                "\"type\": {\"href\": \(varToString(typeLink))}," +
                "\"status\": {\"href\": \(varToString(statusLink))}," +
                "\"assignee\": {\"href\": \(varToString(assigneeLink))}," +
                "\"responsible\": {\"href\": \(varToString(responsibleLink))}," +
                "\"category\": {\"href\": \(varToString(categoryLink)) }," +
                "\"version\": {\"href\": \(varToString(versionLink))}," +
                "\"priority\": {\"href\": \(varToString(priorityLink))}," +
                "\"parent\": {\"href\": \(varToString(parentLink))}," +
                "\"costObject\": {\"href\": \(varToString(costObject))}" +
            "}," +
            "\"lockVersion\": \(lockVersion!)," +
            "\"subject\": \(varToString(subject))," +
            "\"percentageDone\": \(percentageDone)," +
            "\"estimatedTime\": \(varToString(estimatedTime))," +
            "\"description\": {\"format\": \"textile\",\"raw\": \(varToString(descriptionRaw)),\"html\": \(varToString(descriptionHtml))}," +
            "\"parentId\": \(intToString(parentId))," +
            "\"startDate\": \(dateToString(startDate))," +
            "\"dueDate\": \(dateToString(dueDate))," +
            "\"remainingTime\": \(varToString(remainingTime))" +
        "}"
    }
    
    func varToString(_ str: String?) -> String {
        if let s = str {
            return "\"\(s)\""
        } else {
            return "null"
        }
    }
    
    func intToString(_ int: Int?) -> String {
        if let i = int {
            return "\(i)"
        } else {
            return "null"
        }
    }
    
    func dateToString(_ date: Date?) -> String {
        if date != nil {
            return "SOMEDATE"
        } else {
            return "null"
        }
    }
}
