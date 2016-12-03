//
//  EditDateVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 02/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol EditDateVCDelegate {
    func dateEditFinished()
}

class EditDateVC: UIViewController {

    var schemaItem: WorkPackageFormSchema?
    
    @IBOutlet weak var labelDate: UILabel!
    
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    var selectedDate:Date?
    
    var delegate: EditDateVCDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        buttonClear.backgroundColor = Colors.lightAzureOP.getUIColor()
        buttonClear.tintColor = UIColor.white
        datePicker.backgroundColor = UIColor.white
        datePicker.datePickerMode = .date
    
        labelDate.textAlignment = .center
        labelDate.font = UIFont.boldSystemFont(ofSize: 44)
        labelDate.textColor = Colors.darkAzureOP.getUIColor()
        
        labelDate.text = "NOT SET"
        
        selectedDate = Date()
        
        if let date = selectedDate {
            datePicker.setDate(date, animated: false)
            labelDate.text = setDateLabel(date: date)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let date = selectedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            schemaItem?.value = formatter.string(from: date)
        } else {
            schemaItem?.value = nil
        }
        
        WorkPackageFormSchema.updateValue(schemaItem: schemaItem!)
        delegate?.dateEditFinished()
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
        selectedDate = datePicker.date
        if let date = selectedDate {
            labelDate.text = setDateLabel(date: date)
        }
    }
    
    @IBAction func buttonClearTapped(_ sender: Any) {
        selectedDate = nil
        labelDate.text = "NOT SET"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func setDateLabel(date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }
}
