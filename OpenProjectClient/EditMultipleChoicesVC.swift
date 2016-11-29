//
//  EditMultipleChoicesVC.swift
//  OpenProjectClient
//
//  Created by Miloslav Linhart on 29/11/16.
//  Copyright © 2016 Miloslav Linhart. All rights reserved.
//

import UIKit

protocol EditMultipleChoicesVCDelegate {
    func multipleChoicesEditFinished()
}

class EditMultipleChoicesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var values: [(id: Int, name: String, href: String)] = []
    var delegate: EditMultipleChoicesVCDelegate?
    var type: WpAttributes?
    var selectedTitle: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.automaticallyAdjustsScrollViewInsets = false
        //don't show empty rows
        self.tableView.tableFooterView = UIView()
        
        self.view.backgroundColor = Colors.paleOP.getUIColor()
        
        tableView.dataSource = self
        tableView.delegate = self
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

    //UITableViewDataSource + UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditMultipleChoicesTVC") as! EditMultipleChoicesTVC!
        let item = values[indexPath.row]
        cell?.accessoryType = .none
        cell?.selectionStyle = .none
        cell?.textLabel?.text = item.name
        if item.name == selectedTitle {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
        }
        return cell!;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //update newWorkPackage
        let v = values[indexPath.row]
        switch type! {
        case WpAttributes.type:
            WorkPackageForm.updateType(title: v.name, href: v.href)
            delegate?.multipleChoicesEditFinished()
            break
        case WpAttributes.status:
            WorkPackageForm.updateStatus(title: v.name, href: v.href)
            delegate?.multipleChoicesEditFinished()
            break
        case WpAttributes.priority:
            WorkPackageForm.updatePriority(title: v.name, href: v.href)
            delegate?.multipleChoicesEditFinished()
            break
        case WpAttributes.assignee:
            if v.id != -1 {
                WorkPackageForm.updateAssignee(title: v.name, href: v.href)
            } else {
                WorkPackageForm.updateAssignee(title: nil, href: nil)
            }
            delegate?.multipleChoicesEditFinished()
            break
        case WpAttributes.responsible:
            if v.id != -1 {
                WorkPackageForm.updateResponsible(title: v.name, href: v.href)
            } else {
                WorkPackageForm.updateResponsible(title: nil, href: nil)
            }
            delegate?.multipleChoicesEditFinished()
            break
        case WpAttributes.version:
            if v.id != -1 {
                WorkPackageForm.updateVersion(title: v.name, href: v.href)
            } else {
                WorkPackageForm.updateVersion(title: nil, href: nil)
            }
            delegate?.multipleChoicesEditFinished()
            break
        default:
            break
        }
    }
}
