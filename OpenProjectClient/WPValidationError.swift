//
//  WPValidationError.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 04/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import SwiftyJSON

class WPValidationError {
    var name: String?
    var message: String?
    
    class func getValidationErrors(json: JSON) -> [WPValidationError] {
        
        let errors = json["_embedded"]["validationErrors"].dictionary
        
        var results = [WPValidationError]()
        
        for key in (errors?.keys)! {
            
            let err = WPValidationError()
            if let message = errors?[key]?["message"].string {
                err.message = message
                err.name = key
            }
            results.append(err)
        }
        return results
    }
    
    class func getSubmitionErrors(json: JSON) -> [WPValidationError] {
        
        let errors = json.dictionary
        
        var results = [WPValidationError]()
        
        if let name = errors?["_type"]?.string {
            if name == "Error" {
                for key in (errors?.keys)! {
                    
                    let err = WPValidationError()
                    if let message = errors?[key]?["message"].string {
                        err.message = message
                        err.name = key
                    }
                    results.append(err)
                }
            }
        }
        return results
    }
}
