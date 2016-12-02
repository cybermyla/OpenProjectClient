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
        setBackButton()
        setTitle()
        
        self.textView.text = schemaItem?.value
        self.textView.becomeFirstResponder()
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
    
    func setTitle() {
        /*
        switch (self.schemaItem?.type)! {
        case "subject":
            self.title = "Subject"
            break
        case "description":
            self.title = "Description"
            break
        default:
            break
        }
         */
    }
    
    func setBackButton() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditLongTextVC.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    func back(sender: UIBarButtonItem) {
        var ok = true
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let minLength = schemaItem?.minLength{
            if minLength > 0 && text.characters.count < Int(minLength) {
                ok = false
                showNoIncorrectLengthAlert()
            }
        }
        if let maxLength = schemaItem?.maxLength {
            if maxLength > 0 && text.characters.count > Int(maxLength) {
                ok = false
                showNoIncorrectLengthAlert()
            }
        }
        if ok {
            schemaItem?.value = text
            WorkPackageFormSchema.updateValue(schemaItem: schemaItem!)
            delegate?.longTextEditFinished()
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func showNoIncorrectLengthAlert() {
        let alertController = UIAlertController(title: "ERROR", message: "\((self.schemaItem?.name!)!) length has to be between \((self.schemaItem?.minLength)!) and \((self.schemaItem?.maxLength)!)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch (action.style) {
            case .default:
                //self.dismiss(animated: true, completion: nil)
                break
            default:
                break
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }

}
