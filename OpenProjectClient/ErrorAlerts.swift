//
//  ErrorAlerts.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 11/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import Foundation
import SwiftyJSON

class ErrorAlerts {
    
    static func getAlertController(error: Error, sender: UIViewController) -> UIAlertController {
        let alertController = UIAlertController(title: "ERROR", message: getErrorText(errorCode: error._code), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            switch (action.style) {
            case .default:
                sender.dismiss(animated: true, completion: nil)
                break
            default:
                break
            }
        }))
        return alertController
    }
    
    static func getAlertController(title: String, message: String, sender: UIViewController) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            switch (action.style) {
            case .default:
                sender.dismiss(animated: true, completion: nil)
                break
            default:
                break
            }
        }))
        return alertController
    }
    
    static func getAlertController(errors: [ResponseValidationError], sender: UIViewController) -> UIAlertController {
        var errorText = [String]()
        for error in errors {
            errorText.append(error.message!)
        }
        let alertController = UIAlertController(title: "ERROR", message: errorText.joined(separator: "\n"), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            switch (action.style) {
            case .default:
                sender.dismiss(animated: true, completion: nil)
                break
            default:
                break
            }
        }))
        return alertController
    }
    
    private static func getErrorText(errorCode: Int) -> String {
        print("Error \(errorCode)")
        switch errorCode {
        case -1001:
            return "Request Timed out"
        case 400, 401, 403, 404, 409, 415, 422:
            return "Client error"
        case 3:
            return "Authentication error"
        case 500:
            return "Server side error"
        default:
            return "General error"
        }
    }
}
