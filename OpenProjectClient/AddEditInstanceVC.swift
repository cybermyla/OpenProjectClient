//
//  AddEditSettingsViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol AddEditInstanceVCDelegate {
    func instanceSaved(_ instanceId: String)
}

class AddEditInstanceVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textFieldAddress: UITextField!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var textFieldApiKey: UITextField!
    
    var delegate: AddEditInstanceVCDelegate?
    //var currentInstance: Instance!
    var currentInstanceAddress: String?
    var currentInstanceApiKey: String?
    
    var edit: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        textFieldAddress.delegate = self
        textFieldApiKey.delegate = self
        
        setStyles()
        
        if let _ = currentInstanceAddress {
            //EDIT
            self.title = currentInstanceAddress
            textFieldAddress.text = currentInstanceAddress
            textFieldApiKey.text = currentInstanceApiKey
            
        } else {
            //CREATE
            edit = false
            self.title = "New Instance"
        }   
        /*
        textFieldAddress.text = "http://10.0.0.43"
        textFieldApiKey.text = "7b0d7c5e7c0fa1089d2426c69b2c8013052a43e7"

          */
        textFieldAddress.text = "https://community.openproject.com"
        textFieldApiKey.text = "9cfa5e3eea8f3537c50d30c2a0f6bb14a40f0217"
 
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        currentInstanceAddress = textFieldAddress.text
        currentInstanceApiKey = textFieldApiKey.text
        
        getInstanceDetails()
    }

    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        if (!edit) {

        }
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func setStyles() {

        let paddingForAddress = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.textFieldAddress.frame.size.height))
        self.textFieldAddress.leftView = paddingForAddress
        self.textFieldAddress.leftViewMode = UITextFieldViewMode .always
 
        let paddingForApiKey = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.textFieldApiKey.frame.size.height))
        self.textFieldApiKey.leftView = paddingForApiKey
        self.textFieldApiKey.leftViewMode = UITextFieldViewMode .always
        
        textFieldAddress.returnKeyType = .done
        textFieldApiKey.returnKeyType = .done
        
        textFieldApiKey.isSecureTextEntry = true
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        buttonSave.backgroundColor = Colors.darkAzureOP.getUIColor()
        buttonCancel.backgroundColor = Colors.lightAzureOP.getUIColor()
    }
    
    //textfield delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getInstanceDetails() {
        OpenProjectAPI.sharedInstance.getInstance(currentInstanceAddress!, apikey: currentInstanceApiKey!, onCompletion: {(responseObject:Instance?, error:NSError?) in
            if let issue = error {
                print(issue.description)
            } else {
                if let fetchedInstance = responseObject {
                    print("Version: \(fetchedInstance.coreVersion), InstanceName: \(fetchedInstance.instanceName)")
                    self.delegate?.instanceSaved(fetchedInstance.id!)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
}
