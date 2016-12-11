//
//  AddWorkpackageActivityVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 08/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol AddWorkPackageVCDelegate {
    func commentSubmitted()
}

class AddWorkpackageActivityVC: UIViewController, UITextViewDelegate {
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var textFieldText: UITextView!
    @IBOutlet weak var buttonCancel: UIButton!
    
    var delegate: AddWorkPackageVCDelegate?
    var workPackage: WorkPackage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupGraphics()
        textFieldText.text = ""
        textFieldText.autocorrectionType = .no
        textFieldText.becomeFirstResponder()
        
        textFieldText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        get {
            return true
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func buttonSendTapped(_ sender: Any) {
        textFieldText.resignFirstResponder()
        sendActivityComment()
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        textFieldText.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendActivityComment() {
        let text = textFieldText.text.replacingOccurrences(of: "\n", with: "\\n")
        //if text.characters.count > 0 {
            let payload = "{\"comment\": { \"raw\": \"\(text)\" }}"
            if let wpId = self.workPackage?.id {
                OpenProjectAPI.sharedInstance.sendActivityComment(payload: payload, workPackageId: wpId, onCompletion: {(responseObject: JSON, error:NSError?) in
                    if let issue = error {
                        print(issue.description)
                        LoadingUIView.hide()
                    } else {
                        if self.checkIfSubmitSuccesfull(json: responseObject) {
                            LoadingUIView.hide()
                            self.delegate?.commentSubmitted()
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            self.textFieldText.becomeFirstResponder()
                            LoadingUIView.hide()
                        }
                    }
                })
            }
        //}
    }
    
    func setupGraphics() {
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        
        buttonSend.backgroundColor = Colors.darkAzureOP.getUIColor()
        buttonSend.tintColor = UIColor.white
        
        buttonCancel.backgroundColor = Colors.lightAzureOP.getUIColor()
        buttonCancel.tintColor = UIColor.white
    }
    
    func checkIfSubmitSuccesfull(json: JSON) -> Bool {
        switch json["_type"].stringValue {
        case "Activity::Comment":
            return true
        case "Error":
            return false
        case "Activity":
            return true
        default:
            return false
        }
    }

}
