//
//  EditDateVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 02/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

class EditDateVC: UIViewController {

    var schemaItem: WorkPackageFormSchema?
    
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        buttonClear.backgroundColor = Colors.lightAzureOP.getUIColor()
        buttonClear.tintColor = UIColor.white
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
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
    
    @IBAction func datePickerValueChanged(_ sender: Any) {
    }
    
    @IBAction func buttonClearTapped(_ sender: Any) {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
