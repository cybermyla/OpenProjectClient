//
//  Tools.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 06/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation

class Tools {
    static func dateToFormatedString(date: Date, style: DateFormatter.Style) -> String {
        let df = DateFormatter()
        df.dateStyle = style
        return df.string(from: date)
    }
}
