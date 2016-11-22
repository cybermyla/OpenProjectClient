//
//  WPFilter+CoreDataClass.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 31/10/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData


public class WPFilter: NSManagedObject {
    
    static func getWPFilter(_ projectId: NSNumber, instanceId: String) -> String {

        let predicate = NSPredicate(format: "instanceId = %@ AND projectId == %@ AND selected == true", argumentArray: [instanceId, projectId])
        if let wpFilter = WPFilter.mr_findFirst(with: predicate) {
            let types = wpFilter.types as! [Int]
            let priorities = wpFilter.priorities as! [Int]
            let statuses = wpFilter.statuses as! [Int]
            
            var arrFilters: [String] = []
            if types.count > 0 {
                arrFilters.append(getFilterString(name: "type", array: types))
            }
            if priorities.count > 0 {
                arrFilters.append(getFilterString(name: "priority", array: priorities))
            }
            if statuses.count > 0 {
                arrFilters.append(getFilterString(name: "status", array: statuses))
            }
            
            let filter = "&filters=[\(arrFilters.joined(separator: ","))]"
  
            print("Using filter \(filter)")
            return filter.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        } else {
            return ""
        }
    }
    
    static func getFilters(_ projectId: NSNumber, instanceId: String) -> [WPFilter]{
        let predicate = NSPredicate(format: "instanceId = %@ AND projectId == %@", argumentArray: [instanceId, projectId])
        return WPFilter.mr_findAll(with: predicate) as! [WPFilter]
    }
    
    static func deselectAllFilters(_ projectId: NSNumber, instanceId: String) {
        let predicate = NSPredicate(format: "instanceId = %@ AND projectId == %@", argumentArray: [instanceId, projectId])
        let filters = WPFilter.mr_findAll(with: predicate) as! [WPFilter]
        
        for filter in filters {
            filter.selected = false
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func selectFilter(_ filter: WPFilter) {
        let predicate = NSPredicate(format: "instanceId = %@ AND projectId == %@ AND name == %@", argumentArray: [filter.instanceId!, filter.projectId, filter.name!])

        let filter = WPFilter.mr_findFirst(with: predicate) as WPFilter
        filter.selected = true
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func deselectFilter(_ filter: WPFilter) {
        let predicate = NSPredicate(format: "instanceId = %@ AND projectId == %@ AND name == %@", argumentArray: [filter.instanceId!, filter.projectId, filter.name!])
        
        let filter = WPFilter.mr_findFirst(with: predicate) as WPFilter
        filter.selected = false
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    static func deleteWPFilter(filter: WPFilter) {
        let predicate = NSPredicate(format: "instanceId = %@ AND projectId == %@ AND name == %@", argumentArray: [filter.instanceId!, filter.projectId, filter.name!])
        WPFilter.mr_deleteAll(matching: predicate)
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    private static func getFilterString(name: String, array: [Int]) -> String {
        var list: [String] = []
        for item in array {
            list.append("\u{22}\(item)\u{22}")
        }
        return "{\u{22}\(name)\u{22}: {\u{22}operator\u{22}: \u{22}=\u{22},\u{22}values\u{22}: [\(list.joined(separator: ","))]}}"
    }
    
    static func getFilterOneLineDescription(_ projectId: NSNumber?, instanceId: String?) -> String {
        
        if projectId != nil && instanceId != nil {
            let predicate = NSPredicate(format: "instanceId = %@ AND projectId == %@ AND selected == true", argumentArray: [instanceId!, projectId!])
            let filter = WPFilter.mr_findFirst(with: predicate) as WPFilter?
            if filter != nil  {
                var values: [String] = []
                if let typeNames = filter?.typeNames as? [String] {
                    values.append(arrayToString(arr: typeNames))
                } else { values.append("All") }
                
                if let statusNames = filter?.statusNames as? [String] {
                    values.append(arrayToString(arr: statusNames))
                } else {values.append("All") }
                
                if let priorityNames = filter?.priorityNames as? [String] {
                    values.append(arrayToString(arr: priorityNames))
                } else {values.append("All") }
                return "\(values[0])|\(values[1])|\(values[2])"
            } else {
                return ""
            }
        } else {
            return ""
        }
    }
    
    private static func arrayToString(arr: [String]) -> String {
        if arr.count > 0 {
            return arr.joined(separator: ",")
        } else {
            return "All"
        }
    }
}
