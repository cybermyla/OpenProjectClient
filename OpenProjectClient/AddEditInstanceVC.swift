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
    
    let defaults = UserDefaults.standard
    
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
            
            let mySettings = DevSettings()
            if let address = mySettings.address {
                textFieldAddress.text = address
            }
            if let key = mySettings.key {
                textFieldApiKey.text = key
            }
        }
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
        LoadingUIView.show()
        OpenProjectAPI.sharedInstance.getInstance(currentInstanceAddress!, apikey: currentInstanceApiKey!, onCompletion: {(responseObject:Instance?, error:NSError?) in
            if let issue = error {
                self.showRequestErrorAlert(error: issue)
                print(issue.description)
                LoadingUIView.hide()
            } else {
                if let fetchedInstance = responseObject {
                    print("Version: \(fetchedInstance.coreVersion), InstanceName: \(fetchedInstance.instanceName)")
                    self.delegate?.instanceSaved(fetchedInstance.id!)
                    self.defaults.set(fetchedInstance.id!, forKey: "InstanceId")
                    LoadingUIView.hide()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    func showRequestErrorAlert(error: Error) {
        let alertController = ErrorAlerts.getAlertController(error: error, sender: self)
        self.present(alertController, animated: true, completion: nil)
    }
}
