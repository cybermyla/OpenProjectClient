//
//  EditSubjectVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 27/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol EditLongTextVCDelegate {
    func editFinished(type: WpAttributes)
}

class EditLongTextVC: UIViewController {

    var type: WpAttributes?
    var text: String?
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        self.automaticallyAdjustsScrollViewInsets = false
        //hide and recreate custom back button
        setBackButton()
        setTitle()
        
        self.textView.text = text
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
        switch type! {
        case WpAttributes.subject:
            self.title = "Subject"
            break
        case WpAttributes.description:
            self.title = "Description"
            break
        default:
            break
        }
    }
    
    func setBackButton() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(EditLongTextVC.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    func back(sender: UIBarButtonItem) {
        switch type! {
        case WpAttributes.subject:
            WorkPackageForm.updateSubject(str: textView.text)
            break
        case WpAttributes.description:
            WorkPackageForm.updateDescription(str: textView.text)
        default:
            break
        }
        _ = navigationController?.popViewController(animated: true)
    }

}
