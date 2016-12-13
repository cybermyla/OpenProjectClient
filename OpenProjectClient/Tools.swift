//
//  Tools.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 06/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation

class Tools {
    static func dateToFormatedString(date: Date, dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style?) -> String {
        let df = DateFormatter()
        if let tstyle = timeStyle {
            df.timeStyle = tstyle
        }
        df.dateStyle = dateStyle
        return df.string(from: date)
    }
    
    static func createFormatedLabel(_ name: String, str: String) -> NSAttributedString {
        let string = "\(name): \(str) "
        let nonBoldRange = NSRange(location: name.characters.count + 1, length: string.characters.count - name.characters.count - 1)
        return attributedString(from: string, nonBoldRange: nonBoldRange)
    }
    
    static func createParametersLabel(_ name: String, str: String) -> NSAttributedString {
        let strRange = str.index(after: str.startIndex)..<str.index(before: str.endIndex)
        let substr = str.substring(with: strRange)
        if substr.characters.count > 0 {
            let arr = substr.components(separatedBy: ";")
            let string = "\(name): \(arr.joined(separator: ", "))"
            let nonBoldRange = NSRange(location: name.characters.count + 1, length: string.characters.count - name.characters.count - 1)
            let attString = attributedString(from: string, nonBoldRange: nonBoldRange)
            return attString
        } else {
            let string = "\(name): All"
            let nonBoldRange = NSRange(location: name.characters.count + 1, length: string.characters.count - name.characters.count - 1)
            return attributedString(from: string, nonBoldRange: nonBoldRange)
        }
    }
    
    static func durationToInt(duration: String) -> Int32 {
        var days: Int32 = 0
        var hours: Int32 = 0
        if duration.contains("D") && duration.contains("H") {
            let arr = matches(for: "[0-9]+", in: duration)
            days = Int32(arr[0])!
            hours = Int32(arr[1])!
        } else if duration.contains("D") && !duration.contains("H") {
            let arr = matches(for: "[0-9]+", in: duration)
            days = Int32(arr[0])!
        } else {
            let arr = matches(for: "[0-9]+", in: duration)
            hours = Int32(arr[0])!
        }
        hours += (days * 24)
        return hours
    }
    
    static func intToDuration(int: Int32) -> String {
        let modulo = int % 24
        let division = int / 24
        if modulo == 0 && division != 0 {
            return "P\(division)D"
        } else if modulo != 0 && division != 0 {
            return "P\(division)DT\(modulo)H"
        } else {
            return "PT\(modulo)H"
        }
    }
    
    static func stringToNSDate(_ str: String) -> NSDate? {
        
        let dateFormatter = DateFormatter()
        if (str.contains("T")) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        
        guard let date = dateFormatter.date(from: str) else {
            return nil
        }
        return date as NSDate?
    }
    
    static func nsDateToString(_ date: NSDate?) -> String? {
        if let d = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return dateFormatter.string(from: d as Date)
        } else {
            return nil
        }
    }
    
    ///PRIVATE FUNCTIONS
    private static func attributedString(from string: String, nonBoldRange: NSRange?) -> NSAttributedString {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: fontSize),
            NSForegroundColorAttributeName: Colors.darkAzureOP.getUIColor()
        ]
        let nonBoldAttribute = [
            NSFontAttributeName: UIFont.italicSystemFont(ofSize: fontSize),
            ]
        let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
        if let range = nonBoldRange {
            attrStr.setAttributes(nonBoldAttribute, range: range)
        }
        return attrStr
    }
    
    private static func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
