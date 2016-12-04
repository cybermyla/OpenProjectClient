//
//  EditHoursVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 03/12/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol EditHoursVCDelegate {
    func hoursEditFinished()
}

class EditHoursVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var labelHours: UILabel!
    
    @IBOutlet weak var clearButton: UIButton!

    @IBOutlet weak var hoursPickerView: UIPickerView!
    
    var schemaItem: WorkPackageFormSchema?
    
    var intValues:[Int] = []
    
    var selectedValue: Int?
    
    var unit: String = ""
    
    var delegate: EditHoursVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        labelHours.textAlignment = .center
        labelHours.font = UIFont.boldSystemFont(ofSize: 44)
        labelHours.textColor = Colors.darkAzureOP.getUIColor()
        
        self.title = schemaItem?.name
        
        if let value = schemaItem?.value_int {
            selectedValue = Int(value)
        }
        hoursPickerView.backgroundColor = UIColor.white
        hoursPickerView.dataSource = self
        hoursPickerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let value = selectedValue {
            if let index = intValues.index(of: value) {
                hoursPickerView.selectRow(index, inComponent: 0, animated: false)
                labelHours.text = (schemaItem?.value?.characters.count)! >= 0 ? schemaItem?.value : "NOT SET"
            } else {
                labelHours.text = "0 \(unit)"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let value = selectedValue {
            schemaItem?.value = "\(value)"
        }
        WorkPackageFormSchema.updateValue(schemaItem: schemaItem!)

        delegate?.hoursEditFinished()
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = intValues[row]
        switch intValues[row] {
        case -1:
            labelHours.text = "NOT SET"
            break
        default:
            labelHours.text = "\(intValues[row]) \(unit)"
            break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return intValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch intValues[row] {
        case -1:
            return "NOT SET"
        default:
            return "\(intValues[row]) \(unit)"
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
