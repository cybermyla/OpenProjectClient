//
//  AddEditSettingsViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol AddEditInstanceVCDelegate {
    func instanceSaved(instanceId: String)
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
        
        textFieldAddress.text = "https://community.openproject.org"
        textFieldApiKey.text = "9cfa5e3eea8f3537c50d30c2a0f6bb14a40f0217"
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        currentInstanceAddress = textFieldAddress.text
        currentInstanceApiKey = textFieldApiKey.text
        
        getInstanceDetails()
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if (!edit) {

        }
        self.dismissViewControllerAnimated(true, completion: nil)
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

        let paddingForAddress = UIView(frame: CGRectMake(0, 0, 15, self.textFieldAddress.frame.size.height))
        self.textFieldAddress.leftView = paddingForAddress
        self.textFieldAddress.leftViewMode = UITextFieldViewMode .Always
 
        let paddingForApiKey = UIView(frame: CGRectMake(0, 0, 15, self.textFieldApiKey.frame.size.height))
        self.textFieldApiKey.leftView = paddingForApiKey
        self.textFieldApiKey.leftViewMode = UITextFieldViewMode .Always
        
        textFieldAddress.returnKeyType = .Done
        textFieldApiKey.returnKeyType = .Done
        
        textFieldApiKey.secureTextEntry = true
        self.view.backgroundColor = Colors.PaleOP.getUIColor()
        buttonSave.backgroundColor = Colors.DarkAzureOP.getUIColor()
        buttonCancel.backgroundColor = Colors.LightAzureOP.getUIColor()
    }
    
    //textfield delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
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
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        })
    }
}
