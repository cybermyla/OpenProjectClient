//
//  WorkPackageFormSchema+CoreDataClass.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 01/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON


public class WorkPackageFormSchema: NSManagedObject {
    
    var value: String? {
        get {
            if let type = WpTypes(rawValue: Int(self.type)) {
                switch type {
                case WpTypes.formattable:
                    return self.value_str_raw
                case WpTypes.string:
                    return self.value_string
                case WpTypes.date:
                    if let date = self.value_dateTime as? Date {
                        return Tools.dateToFormatedString(date: date, dateStyle: .medium, timeStyle: nil)
                    } else {
                        return nil
                    }
                case WpTypes.dateTime:
                    return "\(self.value_dateTime)"
                case WpTypes.duration:
                    switch self.value_int {
                    case -1:
                        return ""
                    case 1:
                        return "1 hour"
                    default:
                        return "\(self.value_int) hours"
                    }
                case WpTypes.integer:
                    switch self.value_int {
                    case -1:
                        return "0"
                    default:
                        return "\(self.value_int)"
                    }
                case WpTypes.complex:
                    return self.value_title
                case WpTypes.stringObject:
                    return self.value_title
                }
            }
            return "problem"
        }
    
        
        set (newValue) {
            if let type = WpTypes(rawValue: Int(self.type)) {
                switch type {
                case WpTypes.formattable:
                    self.value_str_raw = newValue
                    break
                case WpTypes.string:
                    self.value_string = newValue
                    break
                case WpTypes.date:
                    if let strValue = newValue {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        self.value_dateTime = formatter.date(from: strValue) as NSDate?
                    } else {
                        self.value_dateTime = nil
                    }
                    break
                case WpTypes.dateTime:
                    //self.value_dateTime = newValue
                    break
                case WpTypes.duration:
                    if let value = newValue {
                        if let firstCharacter = value.characters.first {
                            if firstCharacter == "P" {
                                self.value_int = Tools.durationToInt(duration: value)
                            } else {
                                self.value_int = Int32(value)!
                            }
                        }
                    }
                    break
                case WpTypes.integer:
                    if let value = newValue {
                        self.value_int = Int32(value)!
                    }
                    break
                case WpTypes.complex, WpTypes.stringObject:
                    if let arr = newValue?.components(separatedBy: ";") {
                        self.value_title = arr[0]
                        self.value_href = arr[1]
                    } else {
                        self.value_title = nil
                        self.value_href = nil
                    }
                    break
                }
            }
        }
    }
    
    var valuePayload: String {
        get {
            if let type = WpTypes(rawValue: Int(self.type)) {
                switch type {
                case WpTypes.formattable:
                    var raw = "null"
                    if let value = self.value_str_raw {
                        raw = "\"\(value)\""
                    }
                    var html: String = ""
                    if let value = self.value_str_html {
                        html = "\"\(value)\""
                    }
                    return "\"\(self.schemaItemName!)\": { \"raw\": \(raw), \"format\": \"textile\", \"html\": \(html) }"
                case WpTypes.string:
                    if let value = self.value_string {
                        return "\"\(self.schemaItemName!)\": \"\(value)\""
                    } else {
                        return "\"\(self.schemaItemName!)\": null"
                    }
                case WpTypes.date:
                    if let value = self.value_dateTime {
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd"
                        return "\"\(self.schemaItemName!)\": \"\(df.string(from: value as Date))\""
                    } else {
                        return "\"\(self.schemaItemName!)\": null"
                    }
                case WpTypes.dateTime:
                    if let value = self.value_dateTime {
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd"
                        return "\"\(self.schemaItemName!)\": \"\(df.string(from: value as Date))\""
                    } else {
                        return "\"\(self.schemaItemName!)\": null"
                    }
                case WpTypes.duration:
                    if self.value_int >= 0 {
                        return "\"\(self.schemaItemName!)\": \"\(Tools.intToDuration(int: self.value_int))\""
                    } else {
                        return "\"\(self.schemaItemName!)\": null"
                    }

                case WpTypes.integer:
                    let value = self.value_int
                    if value == -1 {
                        switch self.schemaItemName! {
                        case "parentId", "id":
                            return "\"\(self.schemaItemName!)\": null"
                        default:
                            return "\"\(self.schemaItemName!)\": null"
                        }
                    }
                    return "\"\(self.schemaItemName!)\": \(self.value_int)"
                case WpTypes.complex, WpTypes.stringObject:
                    if let href = self.value_href {
                        return "\"\(self.schemaItemName!)\": { \"title\": \"\(self.value_title!)\", \"href\": \"\(href)\" }"
                    } else {
                        return "\"\(self.schemaItemName!)\": { \"href\": null }"
                    }
                }
            }
            return ""
        }
    }
    class func buildWorkPackageForms(_ projectId: NSNumber, instanceId: String, json: JSON) {
        let arrPayload = json["_embedded"]["payload"].dictionary
        let dicSchemaElements = json["_embedded"]["schema"].dictionary
        
        WorkPackageFormSchema.mr_truncateAll()
        StringObjectValue.mr_truncateAll()
        
        for key in (dicSchemaElements?.keys)! {
            
            let element = dicSchemaElements?[key]
            
            let schema = WorkPackageFormSchema.mr_createEntity()

            if let value = element?["visibility"].string {
                schema?.visibility = value
            }
            if let value = element?["hasDefault"].bool {
                schema?.hasDefault = value
            }
            if let value = element?["type"].string {
                let type = stringToTypeEnumInt(str: value)
                schema?.type = type
                //get default 
                if let typeEnum = WpTypes(rawValue: Int(type)) {
                    switch typeEnum {
                    case WpTypes.complex, WpTypes.stringObject:
                    if let href = arrPayload?["_links"]?[key]["href"].string {
                        if let title = arrPayload?["_links"]?[key]["title"].string {
                            schema?.value_href = href
                            schema?.value_title = title
                        }
                    }
                    break
                    case WpTypes.formattable:
                        if let raw = arrPayload?[key]?["raw"].string {
                            schema?.value_str_raw = raw
                        }
                        if let html = arrPayload?[key]?["html"].string {
                            schema?.value_str_html = html
                        }
                        break
                    case WpTypes.integer:
                        if let keyValue = arrPayload?[key]?.int {
                            schema?.value = "\(keyValue)"
                        }
                        break
                    default:
                    if let keyValue = arrPayload?[key]?.string {
                        schema?.value = keyValue
                    }
                    break
                    }
                    
                    //if StringObjectValue (custom attributes)
                    if typeEnum == WpTypes.stringObject {
                        StringObjectValue.buildStringObjectValue(json: json, schemaItemName: key)
                    }
                }
                
            }
            if let value = element?["hasDefault"].bool {
                schema?.hasDefault = value
            }
            if let value = element?["required"].bool {
                schema?.required = value
            }
            if let value = element?["name"].string {
                schema?.name = value
            }
            if let value = element?["writable"].bool {
                schema?.writable = value
            }
            if let value = element?["maxLength"].int {
                schema?.maxLength = Int32(value)
            }
            if let value = element?["minLength"].int {
                schema?.minLength = Int32(value)
            }
            schema?.schemaItemName = key
            
            //set position and section for known items - custom (uknown) will have a separate section
            //including only writable
            if (schema?.writable)! {
                if let section = getSection(itemName: key) {
                    schema?.section = section
                }
                if let position = getPosition(itemName: key) {
                    schema?.position = position
                }
            }
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }

    private static func getSection(itemName: String) -> Int32? {
        //will be skipping parent, parentId
        
        switch itemName {
        case "subject", "description":
            return 0
        case "type", "status", "priority", "startDate", "dueDate", "version", "category", "percentageDone":
            return 1
        case "assignee", "responsible":
            return 2
        case "estimatedTime", "remainingTime", "spentTime":
            return 3
        case "parent", "parentId", "project":
            return -1
        default:
            return 4
        }
    }
    
    private static func getPosition(itemName: String) -> Int32? {
        let arr = ["subject", "description", "type", "status",
                   "priority", "category", "percentageDone", "startDate", "dueDate", "version",
                   "assignee", "responsible", "estimatedTime", "remainingTime", "spentTime"]
        if let index = arr.index(of: itemName) {
            return Int32(index)
        } else {
            return nil
        }
    }
    
    static func getItemsBySection(section: Int32) -> [WorkPackageFormSchema]{
        let predicate = NSPredicate(format: "section = %i AND writable = %i", argumentArray: [section, true])
        return WorkPackageFormSchema.mr_findAllSorted(by: "position", ascending: true, with: predicate) as! [WorkPackageFormSchema]
    }
    
    private static func stringToTypeEnumInt(str: String) -> Int32 {
        switch str {
        case "Formattable":
            return Int32(WpTypes.formattable.rawValue)
        case "String":
            return Int32(WpTypes.string.rawValue)
        case "Date":
            return Int32(WpTypes.date.rawValue)
        case "DateTime":
            return Int32(WpTypes.dateTime.rawValue)
        case "Duration":
            return Int32(WpTypes.duration.rawValue)
        case "Integer":
            return Int32(WpTypes.integer.rawValue)
        case "StringObject":
            return Int32(WpTypes.stringObject.rawValue)
        default:
            return Int32(WpTypes.complex.rawValue)
        }
    }
    
    static func updateValue(schemaItem: WorkPackageFormSchema) {
        let predicate = NSPredicate(format: "name = %i", argumentArray: [schemaItem.name!])
        let item = WorkPackageFormSchema.mr_findFirst(with: predicate) as WorkPackageFormSchema
        if let type = WpTypes(rawValue: Int(schemaItem.type)) {
            switch type {
            case WpTypes.complex, WpTypes.stringObject:
                item.value_href = schemaItem.value_href
                item.value_title = schemaItem.value_title
            case WpTypes.date:
                item.value_dateTime = schemaItem.value_dateTime
                break
            case WpTypes.duration, WpTypes.integer:
                item.value_int = schemaItem.value_int
            default:
                item.value = schemaItem.value
                break
            }
            NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        }
    }
    
    static func getPayload() -> String {
        let items = WorkPackageFormSchema.mr_findAll() as! [WorkPackageFormSchema]
        var complexItems = [String]()
        var otherItems = [String]()
        
        for itm in items {
            if itm.name != nil {
                    let type = WpTypes(rawValue: Int(itm.type))
                    switch type! {
                    case WpTypes.complex, WpTypes.stringObject:
                        complexItems.append(itm.valuePayload)
                        break
                    default:
                        let value = itm.valuePayload.replacingOccurrences(of: "\n", with: "\\n")
                        otherItems.append(value)
                        break
                    }
            }
        }
        var result = [String]()
        result.append(otherItems.joined(separator: ","))
        result.append("\"_links\": {\(complexItems.joined(separator: ","))}")
        return "{\(result.joined(separator: ","))}"
    }
    
    static func getValidatedPayload(json: JSON) -> String {
        let dicPayload = json["_embedded"].dictionary
        return (dicPayload?["payload"]?.rawString())!
    }
}
