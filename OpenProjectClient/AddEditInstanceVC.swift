//
//  AddEditSettingsViewController.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 24/10/15.
//  Copyright © 2015 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol AddEditInstanceVCDelegate {
    func instanceSaved()
}

class AddEditInstanceVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textFieldInstanceName: UITextField!
    @IBOutlet weak var textFieldAddress: UITextField!
    
    @IBOutlet weak var textFieldLogin: UITextField!
    
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    var delegate: AddEditInstanceVCDelegate?
    var currentInstance: Instance!
    
    var edit: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view
        
        textFieldInstanceName.delegate = self
        textFieldAddress.delegate = self
        textFieldLogin.delegate = self
        textFieldPassword.delegate = self
        
        setStyles()
        
        if let _ = currentInstance {
            //EDIT
        } else {
            //CREATE
            edit = false
            currentInstance = Instance.MR_createEntity() as Instance
            currentInstance!.name = ""
            currentInstance!.address = ""
            currentInstance!.login = ""
            currentInstance!.password = ""
            currentInstance!.id = NSUUID().UUIDString
        }
        
        textFieldInstanceName.text = currentInstance.name
        textFieldAddress.text = currentInstance.address
        textFieldLogin.text = currentInstance.login
        textFieldPassword.text = currentInstance.password
        
        if (currentInstance.name == "") {
            self.title = "New Instance"
        } else {
            self.title = currentInstance.name
        }
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
        currentInstance!.name = textFieldInstanceName.text
        currentInstance!.address = textFieldAddress.text
        currentInstance!.login = textFieldLogin.text
        currentInstance!.password = textFieldPassword.text
        
        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
        self.delegate?.instanceSaved()
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if (!edit) {
            currentInstance.MR_deleteEntity()
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
        let paddingForInstanceName = UIView(frame: CGRectMake(0, 0, 15, self.textFieldInstanceName.frame.size.height))
        self.textFieldInstanceName.leftView = paddingForInstanceName
        self.textFieldInstanceName.leftViewMode = UITextFieldViewMode .Always
        
        let paddingForAddress = UIView(frame: CGRectMake(0, 0, 15, self.textFieldAddress.frame.size.height))
        self.textFieldAddress.leftView = paddingForAddress
        self.textFieldAddress.leftViewMode = UITextFieldViewMode .Always
        
        let paddingForLogin = UIView(frame: CGRectMake(0, 0, 15, self.textFieldLogin.frame.size.height))
        self.textFieldLogin.leftView = paddingForLogin
        self.textFieldLogin.leftViewMode = UITextFieldViewMode .Always
        
        let paddingForPassword = UIView(frame: CGRectMake(0, 0, 15, self.textFieldPassword.frame.size.height))
        self.textFieldPassword.leftView = paddingForPassword
        self.textFieldPassword.leftViewMode = UITextFieldViewMode .Always
        
        textFieldInstanceName.returnKeyType = .Done
        textFieldAddress.returnKeyType = .Done
        textFieldLogin.returnKeyType = .Done
        textFieldPassword.returnKeyType = .Done
        
        textFieldPassword.secureTextEntry = true
        self.view.backgroundColor = Colors.PaleOP.getUIColor()
        buttonSave.backgroundColor = Colors.DarkAzureOP.getUIColor()
        buttonCancel.backgroundColor = Colors.LightAzureOP.getUIColor()
    }
    
    //textfield delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
