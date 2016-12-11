//
//  WPValidationError.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 04/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import SwiftyJSON

class ResponseValidationError {
    var name: String?
    var message: String?
    
    class func getFormErrors(json: JSON) -> [ResponseValidationError]? {
        
        let errors = json["_embedded"]["validationErrors"].dictionary
        
        if let keys = errors?.keys {
            var results = [ResponseValidationError]()
            for key in keys {
                let err = ResponseValidationError()
                if let message = errors?[key]?["message"].string {
                    err.message = message
                    err.name = key
                }
                results.append(err)
            }
            return results.count > 0 ? results : nil
        }
        return nil
    }
    
    class func getRequestErrors(json: JSON) -> [ResponseValidationError]? {
        
        let errors = json.dictionary
        
        if let name = errors?["_type"]?.string {
            if name == "Error" {
                if let identifier = errors?["errorIdentifier"]?.string {
                    var results = [ResponseValidationError]()
                    switch identifier {
                    case "urn:openproject-org:api:v3:errors:MultipleErrors":
                        if let multipleErrors = errors?["_embedded"]?["errors"].array {
                            for singleError in multipleErrors {
                                if let message = singleError["message"].string {
                                    let err = ResponseValidationError()
                                    err.name = ""
                                    err.message = message
                                    results.append(err)
                                }
                            }
                        }
                        break
                    default:
                        for key in (errors?.keys)! {
                            let err = ResponseValidationError()
                            if let message = errors?[key]?["message"].string {
                                err.message = message
                                err.name = key
                            }
                            results.append(err)
                        }
                        break
                    }
                    return results
                }
            }
        }
        return nil
    }
}
