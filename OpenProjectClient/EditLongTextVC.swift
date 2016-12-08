//
//  EditSubjectVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 27/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol EditLongTextVCDelegate {
    func longTextEditFinished()
}

class EditLongTextVC: UIViewController {

    var schemaItem: WorkPackageFormSchema?
    
    var delegate: EditLongTextVCDelegate?
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        self.automaticallyAdjustsScrollViewInsets = false
        //hide and recreate custom back button
        
        self.title = self.schemaItem?.name
        
        self.textView.text = schemaItem?.value
        self.textView.autocorrectionType = .no
        self.textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        schemaItem?.value = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        WorkPackageFormSchema.updateValue(schemaItem: schemaItem!)
        delegate?.longTextEditFinished()
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
}
